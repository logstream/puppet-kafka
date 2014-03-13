require 'spec_helper_acceptance'

describe 'kafka class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'kafka': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    # TODO: Actually implement some acceptance tests.
    describe package('kafka') do
      # The following test does not work yet because we first need to add a yum repository to the test VM from which
      # Puppet can retrieve the Kafka (RPM) package.
      #it { should be_installed }
    end

  end
end
