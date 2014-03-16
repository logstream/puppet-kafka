require 'spec_helper'

describe 'kafka' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['RedHat', 'CentOS', 'Amazon', 'Fedora'].each do |operatingsystem|
        let(:facts) {{
          :osfamily        => osfamily,
          :operatingsystem => operatingsystem,
        }}

        describe "kafka class with default settings on #{osfamily}" do
          let(:params) {{ }}
          # We must mock $::operatingsystem because otherwise this test will
          # fail when you run the tests on e.g. Mac OS X.
          it { should compile.with_all_deps }

          it { should contain_class('kafka::params') }
          it { should contain_class('kafka::install') }
          it { should contain_class('kafka::service').that_subscribes_to('kafka::install') }

          it { should have_kafka__broker__resource_count(0) }
          it { should contain_package('kafka').with_ensure('present') }

          it { should contain_group('kafka').with({
            'ensure'     => 'present',
            'gid'        => 53002,
          })}

          it { should contain_user('kafka').with({
            'ensure'     => 'present',
            'home'       => '/home/kafka',
            'shell'      => '/bin/bash',
            'uid'        => 53002,
            'comment'    => 'Kafka system account',
            'gid'        => 'kafka',
            'managehome' => true,
          })}

          it { should contain_file('/opt/kafka/logs').with({
            'owner' => 'kafka',
            'group' => 'kafka',
            'mode'  => '0755',
          })}

          it { should contain_file('/var/log/kafka').with({
            'owner' => 'kafka',
            'group' => 'kafka',
            'mode'  => '0755',
          })}
        end

        describe "kafka class with limits_manage enabled on #{osfamily}" do
          let(:params) {{
            :limits_manage => true,
          }}
          it { should contain_limits__fragment('kafka/soft/nofile').with_value(65536) }
          it { should contain_limits__fragment('kafka/hard/nofile').with_value(65536) }
        end

        describe "kafka class with disabled group management on #{osfamily}" do
          let(:params) {{
            :group_manage => false,
          }}
          it { should_not contain_group('kafka') }
          it { should contain_user('kafka') }
        end

        describe "kafka class with disabled user management on #{osfamily}" do
          let(:params) {{
            :user_manage  => false,
          }}
          it { should contain_group('kafka') }
          it { should_not contain_user('kafka') }
        end

        describe "kafka class with disabled user and group management on #{osfamily}" do
          let(:params) {{
            :group_manage => false,
            :user_manage  => false,
          }}
          it { should_not contain_group('kafka') }
          it { should_not contain_user('kafka') }
        end

      end
    end
  end

  context 'unsupported operating system' do
    describe 'kafka class without any parameters on Debian' do
      let(:facts) {{
        :osfamily => 'Debian',
      }}

      it { expect { should contain_package('kafka') }.to raise_error(Puppet::Error,
        /The kafka module is not supported on a Debian based system./) }
    end
  end
end
