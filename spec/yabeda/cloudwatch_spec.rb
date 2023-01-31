# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yabeda::Cloudwatch do
  let(:aws_client) do
    fake_client = instance_double('AWS::Cloudwatch::Client')
    allow(fake_client).to receive(:put_metric_data).and_return(nil)

    fake_client
  end

  after do
    Yabeda.reset!
  end

  it 'has a version number' do
    expect(Yabeda::Cloudwatch::VERSION).not_to be nil
  end

  describe 'with simple config' do
    before do
      Yabeda.configure do
        group :test do
          counter :counter, comment: 'Test counter', tags: [:ctag]
          gauge :gauge, comment: 'Test gauge', tags: [:gtag]
          histogram :histogram, comment: 'Test histogram', tags: [:htag], buckets: [1, 5, 10]
        end
      end

      Yabeda.register_adapter(:cloudwatch, Yabeda::Cloudwatch::Adapter.new(connection: aws_client))
      Yabeda.configure!
    end

    context 'with counters' do
      specify 'increment of yabeda counter increments cloudwatch counter' do
        Yabeda.test.counter.increment({ ctag: 'ctag-value' })
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'counter',
                      dimensions: [{ name: 'ctag', value: 'ctag-value' }],
                      value: 1,
                      unit: 'Count',
                    ),
                  ),
                ))
      end
    end

    context 'with gauges' do
      specify 'set of yabeda gauge sets cloudwatch gauge' do
        Yabeda.test.gauge.set({ gtag: 'gtag-value' }, 42)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'gauge',
                      dimensions: [{ name: 'gtag', value: 'gtag-value' }],
                      value: 42,
                      unit: 'Count',
                    ),
                  ),
                ))
      end
    end

    context 'with histograms' do
      specify 'measure of yabeda histogram measures cloudwatch histogram' do
        Yabeda.test.histogram.measure({ htag: 'htag-value' }, 7.5)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'histogram',
                      dimensions: [{ name: 'htag', value: 'htag-value' }],
                      value: 7.5,
                      unit: 'Seconds',
                    ),
                  ),
                ))
      end
    end
  end

  describe 'with default tag' do
    before do
      Yabeda.configure do
        default_tag :global_tag, 'custom_global_tag'

        group :test do
          counter :counter, comment: 'Test counter', tags: [:ctag]
          gauge :gauge, comment: 'Test gauge', tags: [:gtag]
          histogram :histogram, comment: 'Test histogram', tags: [:htag], buckets: [1, 5, 10]
        end
      end

      Yabeda.register_adapter(:cloudwatch, Yabeda::Cloudwatch::Adapter.new(connection: aws_client))
      Yabeda.configure!
    end

    context 'with counters' do
      specify 'increment of yabeda counter increments cloudwatch counter' do
        Yabeda.test.counter.increment({ ctag: 'ctag-value' })
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'counter',
                      dimensions: array_including(
                        { name: 'ctag', value: 'ctag-value' },
                        { name: 'global_tag', value: 'custom_global_tag' },
                      ),
                      value: 1,
                      unit: 'Count',
                    ),
                  ),
                ))
      end
    end

    context 'with gauges' do
      specify 'set of yabeda gauge sets cloudwatch gauge' do
        Yabeda.test.gauge.set({ gtag: 'gtag-value' }, 42)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'gauge',
                      dimensions: array_including(
                        { name: 'gtag', value: 'gtag-value' },
                        { name: 'global_tag', value: 'custom_global_tag' },
                      ),
                      value: 42,
                      unit: 'Count',
                    ),
                  ),
                ))
      end
    end

    context 'with histograms' do
      specify 'measure of yabeda histogram measures cloudwatch histogram' do
        Yabeda.test.histogram.measure({ htag: 'htag-value' }, 7.5)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'histogram',
                      dimensions: array_including(
                        { name: 'htag', value: 'htag-value' },
                        { name: 'global_tag', value: 'custom_global_tag' },
                      ),
                      value: 7.5,
                      unit: 'Seconds',
                    ),
                  ),
                ))
      end
    end
  end

  describe 'with custom unit' do
    before do
      Yabeda.configure do
        group :test do
          counter :counter, comment: 'Test counter', tags: [:ctag], unit: 'Kilobytes'
          gauge :gauge, comment: 'Test gauge', tags: [:gtag], unit: 'Megabytes'
          histogram :histogram, comment: 'Test histogram', tags: [:htag], buckets: [1, 5, 10], unit: 'Hours'
        end
      end

      Yabeda.register_adapter(:cloudwatch, Yabeda::Cloudwatch::Adapter.new(connection: aws_client))
      Yabeda.configure!
    end

    context 'with counters' do
      specify 'increment of yabeda counter increments cloudwatch counter' do
        Yabeda.test.counter.increment({ ctag: 'ctag-value' })
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'counter',
                      value: 1,
                      unit: 'Kilobytes',
                    ),
                  ),
                ))
      end
    end

    context 'with gauges' do
      specify 'set of yabeda gauge sets cloudwatch gauge' do
        Yabeda.test.gauge.set({ gtag: 'gtag-value' }, 42)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'gauge',
                      value: 42,
                      unit: 'Megabytes',
                    ),
                  ),
                ))
      end
    end

    context 'with histograms' do
      specify 'measure of yabeda histogram measures cloudwatch histogram' do
        Yabeda.test.histogram.measure({ htag: 'htag-value' }, 7.5)
        expect(aws_client).to have_received(:put_metric_data)
          .with(hash_including(
                  namespace: 'test',
                  metric_data: array_including(
                    hash_including(
                      metric_name: 'histogram',
                      value: 7.5,
                      unit: 'Hours',
                    ),
                  ),
                ))
      end
    end
  end
end
