require_relative 'spec_helper'

describe 'datomic::default' do	
	let (:full_version) { 'free-1.2.3' }
	let (:local_file_path) { "#{Chef::Config[:file_cache_path]}/datomic-#{full_version}.zip" }
	let (:datomic_user) { 'theuser' }
	let (:user_home_dir) { '/home/theuser/the_user_home_dir' }
  let (:checksum) { '88fda52a9bcd' }

	let :chef_runner do 
    ChefSpec::ChefRunner.new do |node|
      node.set[:datomic][:full_version] = full_version
      node.set[:datomic][:user] = datomic_user
      node.set[:datomic][:user_home_dir] = user_home_dir
      node.set[:datomic][:checksum] = checksum
    end
  end

  let(:chef_run) { chef_runner.converge 'datomic::default' }
  
  subject { chef_run }   

  it { should create_user datomic_user }

  it { should create_remote_file(local_file_path).with(
    :owner => datomic_user,
    :checksum => checksum
    )}

  it { should create_directory(user_home_dir) }

  context 'install directory' do
  	subject { chef_run.directory(user_home_dir) }
  	its(:owner) { should be datomic_user }
  	its(:group) { should be datomic_user } 
  	its(:mode)  { should eql 00755 }
  end

  it { should execute_command("unzip #{local_file_path} -d #{user_home_dir}").with(:cwd => Chef::Config[:file_cache_path]) }

  it { should execute_command("chown -R #{datomic_user}:#{datomic_user} #{user_home_dir}") }
end

