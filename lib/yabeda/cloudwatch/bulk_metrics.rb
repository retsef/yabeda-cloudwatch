# frozen_string_literal: true

require 'concurrent'
require 'json'

module Yabeda
  module Cloudwatch
    # Class for bulk sending metrics to Cloudwatch
    class BulkMetrics
      MAX_METRICS_BULK = 1000
      MAX_BULK_BYTES = 1024.0 * 1024.0
      attr_reader :interval, :auto_flush, :timer

      def initialize(client, auto_flush: true, interval: 3)
        @client = client
        @metrics = []
        @interval = interval
        @auto_flush = auto_flush

        return unless @interval.positive?

        @timer = Concurrent::TimerTask.new(execution_interval: @interval) do
          flush
        end
      end

      def put_metric_data(namespace:, metric_data:)
        @metrics << {
          namespace: namespace,
          metric_data: metric_data,
        }

        return unless auto_flush
        return flush unless @timer

        # Stop and rerun to extend the timer until maximum metrics reach
        @timer.shutdown if @timer.running? && @metrics.size <= MAX_METRICS_BULK
        @timer.execute unless @timer.running?
      end

      # Need some way to test concurrency properly when dispatch metrics and in the meantime not discard the incoming
      def flush
        @metrics.group_by { _1[:namespace] }.each do |namespace, metrics|
          metrics.each_slice(MAX_METRICS_BULK).each do |metric_slices|
            metric_data = metric_slices.flat_map { _1[:metric_data] }

            slice_by_max_payload_allowed(namespace, metric_data).each do |payload_sliced|
              @client.put_metric_data(
                namespace: namespace,
                metric_data: payload_sliced,
              )
            end
          end
        end

        @metrics.clear
      end

      private

      def slice_by_max_payload_allowed(namespace, metric_data)
        slices = []
        cursor = 0
        offset = 0
        # Needs to be optimized. Instead of cycle through all indexes maybe should use chunks instead
        metric_data.size.times.each do
          offset += 1
          slice = metric_data[cursor, offset]

          # When is exceeded the max size, i will get the slice right before
          next unless payload_exceed?({ namespace: namespace, metric_data: slice })

          slice.pop
          slices << slice

          # move to next slice frame
          cursor = offset - 1
          offset = 1
        end

        slices << metric_data[cursor, offset] if slices.size < metric_data.size
        return [metric_data] if slices.empty?

        slices
      end

      def payload_exceed?(items)
        JSON.dump(items).size >= MAX_BULK_BYTES
      end
    end
  end
end
