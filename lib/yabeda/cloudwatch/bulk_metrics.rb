# frozen_string_literal: true

module Yabeda
  module Cloudwatch
    # Class for bulk sending metrics to Cloudwatch
    class BulkMetrics
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

        @timer.execute unless @timer.running?
      end

      def flush
        @metrics.group_by { _1[:namespace] }.each do |namespace, metrics|
          @client.put_metric_data(
            namespace: namespace,
            metric_data: metrics.flat_map { _1[:metric_data] },
          )
        end

        @metrics.clear
      end
    end
  end
end
