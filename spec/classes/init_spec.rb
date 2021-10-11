require 'spec_helper'

describe 'puppet_metrics_collector' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'when systemd is not the init provider' do
    let(:facts) { { puppet_metrics_collector: { have_systemd: false } } }

    it { is_expected.to contain_notify('systemd_provider_warning') }
  end

  context 'when puppet_metrics_collector::system is included first' do
    let(:pre_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end

  context 'when puppet_metrics_collector::system is included last' do
    let(:post_condition) { 'include puppet_metrics_collector::system' }

    it { is_expected.to compile }
  end

  context 'when customizing the collection frequency' do
    let(:params) { { collection_frequency: 10 } }

    ['ace', 'bolt', 'orchestrator', 'puppetdb', 'puppetserver'].each do |service|
      it { is_expected.to contain_file("/etc/systemd/system/puppet_#{service}-metrics.timer").with_content(%r{OnCalendar=.*0\/10}) }
    end
  end
end
