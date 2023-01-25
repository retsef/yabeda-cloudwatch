# frozen_string_literal: true

require "yabeda/base_adapter"

module Yabeda
  module CloudWatch
    class Adapter < ::Yabeda::BaseAdapter
      attr_reader :connection

      def initialize(connection:)
        @connection = connection
      end

      def register_counter!(_)
        # We don't need to register metric
      end

      def perform_counter_increment!(counter, tags, increment)
        connection.put_metric_data(
          namespace: counter.group,
          metric_data: [
            {
              metric_name: counter.name.to_s,
              timestamp: Time.now,
              dimensions: tags.map {|tag_name, tag_value| {name: tag_name, value: tag_value}},
              unit: counter.unit,
              value: increment
            }
          ]
        )
      end

      def register_gauge!(_)
        # We don't need to register metric
      end

      def perform_gauge_set!(gauge, tags, value)
        connection.put_metric_data(
          namespace: gauge.group,
          metric_data: [
            {
              metric_name: gauge.name.to_s,
              timestamp: Time.now,
              dimensions: tags.map {|tag_name, tag_value| {name: tag_name, value: tag_value}},
              unit: gauge.unit,
              value: value
            }
          ]
        )
      end

      def register_histogram!(_)
        # We don't need to register metric
      end

      def perform_histogram_measure!(historam, tags, value)
        connection.put_metric_data(
          namespace: counter.group,
          metric_data: [
            {
              metric_name: counter.name.to_s,
              timestamp: Time.now,
              dimensions: tags.map {|tag_name, tag_value| {name: tag_name, value: tag_value}},
              unit: historam.unit,
              value: value
            }
          ]
        )
      end
    end
  end
end
