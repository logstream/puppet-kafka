require 'spec_helper'

describe 'kafka::broker' do
  let(:title) { 'broker0' }
  let(:pre_condition) {[
      'include ::kafka::params',
      'include ::kafka',
  ]}

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['RedHat', 'CentOS', 'Amazon', 'Fedora'].each do |operatingsystem|
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => operatingsystem,
        }}

        describe "kafka broker with default settings on #{osfamily}" do
          it { should contain_kafka__broker('broker0') }
          it { should contain_class("kafka::params") }
          it { should contain_class("kafka") }

          it { should contain_file('/opt/kafka/config/server-0.properties').
            with_content(/^log.dirs=\/app\/kafka-broker-0/)}
        end

        describe "kafka broker with two directories for $log_dirs on #{osfamily}" do
          let(:params) {{
            :log_dirs => ['/app/kafka-broker-0', '/app/kafka-broker-1'],
          }}

          it { should contain_file('/opt/kafka/config/server-0.properties').
            with_content(/^log.dirs=\/app\/kafka-broker-0,\/app\/kafka-broker-1/)}
        end

      end
    end
  end

end
