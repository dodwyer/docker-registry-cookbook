require_relative 'spec_helper'

site_name = 'docker-registry'

describe file("/etc/nginx/sites-available/#{site_name}.conf") do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_readable.by 'owner' }
  it { should be_readable.by 'group' }
  it { should_not be_writable.by 'group' }
  it { should_not be_writable.by 'others' }

  it "sets up an upstream list" do
    subject.should contain("upstream #{site_name}").
    before(/server {/)
  end

  it "sets the nginx hostname" do
    subject.should contain('server_name registry.example.com').
    after(/server {/)
  end

  it "sets up proxy_pass" do
    subject.should contain("proxy_pass http://#{site_name};").
    after(/server {/)
  end
end

describe file("/etc/nginx/sites-enabled/#{site_name}.conf") do
  it { should be_linked_to "/etc/nginx/sites-available/#{site_name}.conf" }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
