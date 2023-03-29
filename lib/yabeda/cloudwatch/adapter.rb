# frozen_string_literal: true

require 'yabeda/base_adapter'
require 'yabeda/cloudwatch/bulk_metrics'

module Yabeda
  # Yabeda AWS Cloudwatch adapter
  class Cloudwatch::Adapter < BaseAdapter
    attr_reader :connection, :client

    def initialize(connection:, auto_flush: true, auto_flush_interval: 0)
      super()

      @client = connection
      @connection = Cloudwatch::BulkMetrics.new(@client, auto_flush: auto_flush, interval: auto_flush_interval)
    end

    def register_counter!(counter)
      # We don't need to register metric
    end

    def perform_counter_increment!(counter, tags, increment)
      connection.put_metric_data(
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
      connection.put_metric_data(
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
      connection.put_metric_data(
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

    def flush
      @connection.flush
    end
  end
end
