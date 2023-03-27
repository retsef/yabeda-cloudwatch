# frozen_string_literal: true

require 'yabeda/base_adapter'
require 'yabeda/cloudwatch/bulk_metrics'

module Yabeda
  # Yabeda AWS Cloudwatch adapter
  class Cloudwatch::Adapter < BaseAdapter
    attr_reader :connection, :bulk_connection

    def initialize(connection:, bulk: false, bulk_interval: 5)
      super()

      @connection = connection
      @bulk_connection = Cloudwatch::BulkMetrics.new(@connection, interval: bulk_interval) if bulk
    end

    def register_counter!(counter)
      # We don't need to register metric
    end

    def perform_counter_increment!(counter, tags, increment)
      _connection.put_metric_data(
        namespace: counter.group.to_s,
        metric_data: [
          {
            metric_name: counter.name.to_s,
            timestamp: Time.now,
            dimensions: tags.map { |tag_name, tag_value| { name: tag_name.to_s, value: tag_value } },
            unit: (counter.unit || :count).to_s.camelcase,
            value: increment,
          },
        ],
      )
    end

    def register_gauge!(gauge)
      # We don't need to register metric
    end

    def perform_gauge_set!(gauge, tags, value)
      _connection.put_metric_data(
        namespace: gauge.group.to_s,
        metric_data: [
          {
            metric_name: gauge.name.to_s,
            timestamp: Time.now,
            dimensions: tags.map { |tag_name, tag_value| { name: tag_name.to_s, value: tag_value } },
            unit: (gauge.unit || :count).to_s.camelcase,
            value: value,
          },
        ],
      )
    end

    def register_histogram!(histogram)
      # We don't need to register metric
    end

    def perform_histogram_measure!(histogram, tags, value)
      _connection.put_metric_data(
        namespace: histogram.group.to_s,
        metric_data: [
          {
            metric_name: histogram.name.to_s,
            timestamp: Time.now,
            dimensions: tags.map { |tag_name, tag_value| { name: tag_name.to_s, value: tag_value } },
            unit: (histogram.unit || :seconds).to_s.camelcase,
            value: value,
          },
        ],
      )
    end

    private

    def _connection
      bulk_connection || connection
    end
  end
end
