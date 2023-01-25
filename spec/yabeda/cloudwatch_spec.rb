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

  before do
    Yabeda.configure do
      group :test
      counter :counter, comment: 'Test counter', tags: [:ctag]
      gauge :gauge, comment: 'Test gauge', tags: [:gtag]
      histogram :histogram, comment: 'Test histogram', tags: [:htag], buckets: [1, 5, 10]
    end

    Yabeda.register_adapter(:cloudwatch, Yabeda::Cloudwatch::Adapter.new(connection: aws_client))
    Yabeda.configure!
  end

  it 'has a version number' do
    expect(Yabeda::Cloudwatch::VERSION).not_to be nil
  end

  context 'with counters' do
    specify 'increment of yabeda counter increments cloudwatch counter' do
      Yabeda.test.counter.increment({ ctag: 'ctag-value' })
      expect(aws_client).to have_received(:put_metric_data)
    end
  end

  context 'with gauges' do
    specify 'set of yabeda gauge sets cloudwatch gauge' do
      Yabeda.test.gauge.set({ gtag: 'gtag-value' }, 42)
      expect(aws_client).to have_received(:put_metric_data)
    end
  end

  context 'with histograms' do
    specify 'measure of yabeda histogram measures cloudwatch histogram' do
      Yabeda.test.histogram.measure({ htag: 'htag-value' }, 7.5)
      expect(aws_client).to have_received(:put_metric_data)
    end
  end
end
