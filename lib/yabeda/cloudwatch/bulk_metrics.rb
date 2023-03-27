# frozen_string_literal: true

module Yabeda
  module Cloudwatch
    # Class for bulk sending metrics to Cloudwatch
    class BulkMetrics
      attr_reader :interval, :timer

      def initialize(connection, interval: 5)
        @connection = connection
        @metrics = []
        @interval = interval

        @timer = Concurrent::TimerTask.new(execution_interval: @interval) do
          flush
        end
      end

      def put_metric_data(namespace:, metric_data:)
        @metrics << {
          namespace: namespace,
          metric_data: metric_data,
        }

        @timer.execute unless @timer.running?
      end

      def flush
        @metrics.group_by { _1[:namespace] }.each do |namespace, metrics|
          @connection.put_metric_data(
            namespace: namespace,
            metric_data: metrics.flat_map { _1[:metric_data] },
          )
        end
      end
    end
  end
end
