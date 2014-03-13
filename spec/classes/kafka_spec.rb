require 'spec_helper'

describe 'kafka' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['RedHat', 'CentOS', 'Amazon', 'Fedora'].each do |operatingsystem|
        describe "kafka class without any parameters on #{osfamily}" do
          let(:params) {{ }}
          let(:facts) {{
            :osfamily => osfamily,
            :operatingsystem => operatingsystem,
          }}

          # We must mock $::operatingsystem because otherwise this test will
          # fail when you run the tests on e.g. Mac OS X.
          it { should compile.with_all_deps }

          it { should contain_class('kafka::params') }
          it { should contain_class('kafka::install') }
          it { should contain_class('kafka::service').that_subscribes_to('kafka::install') }

          it { should have_kafka__broker__resource_count(0) }
          it { should contain_package('kafka').with_ensure('present') }
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
