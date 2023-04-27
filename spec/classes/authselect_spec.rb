# frozen_string_literal: true

require 'spec_helper'

describe 'authselect' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }

        if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] > '7'
          it { is_expected.to have_package_resource_count(1) }
          # Need to figure out how to mock up authselect check before this works
          # it { is_expected.to have_exec_resource_count(1) }
          it { is_expected.to contain_package('authselect').with_ensure('present') }
          it { is_expected.to contain_exec('authselect set profile=minimal features=[]') }
        else
          it { is_expected.to have_package_resource_count(0) }
          it { is_expected.to have_exec_resource_count(0) }
        end
      end

      context 'yes package, no profile' do
        let(:params) do
          {
            'package_manage' => true,
            'profile_manage' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_package('authselect').with_ensure('present') }
        it { is_expected.to have_exec_resource_count(0) }
      end

      context 'no package, yes profile' do
        let(:params) do
          {
            'package_manage' => false,
            'profile_manage' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
        # Need to figure out how to mock up authselect check before this works
        # it { is_expected.to have_exec_resource_count(1) }
        it { is_expected.to contain_exec('authselect set profile=minimal features=[]') }
      end

      context 'yes package=latest, yes profile' do
        let(:params) do
          {
            'package_manage' => true,
            'package_ensure' => 'latest',
            'package_names'  => ['name1', 'name2'],
            'profile_manage' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_package('name1').with_ensure('latest') }
        it { is_expected.to contain_package('name2').with_ensure('latest') }
        it { is_expected.to have_package_resource_count(2) }
        it { is_expected.to contain_exec('authselect set profile=minimal features=[]') }
      end

      context 'yes package=absent, yes profile' do
        let(:params) do
          {
            'package_manage' => true,
            'package_ensure' => 'absent',
            'profile_manage' => true,
            'profile' => 'testing',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_package('authselect').with_ensure('absent') }
        it { is_expected.to have_exec_resource_count(0) }
      end

      context 'yes package, yes profile, with options' do
        let(:params) do
          {
            'package_manage' => true,
            'profile_manage' => true,
            'profile' => 'testing',
            'profile_options' => ['b', 'a'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        # Need to figure out how to mock up authselect check before this works
        # it { is_expected.to have_exec_resource_count(1) }
        it { is_expected.to contain_package('authselect').with_ensure('present') }
        # it { pp catalogue.resources }
        it { is_expected.to contain_exec('authselect set profile=testing features=[a, b]') }
      end

      context 'yes package, yes profile, with options, already present' do
        before(:each) do
          os_facts[:authselect_profile_features] = ['a', 'b' ]
          os_facts[:authselect_profile] = 'testing'
        end

        let(:params) do
          {
            'package_manage' => true,
            'profile_manage' => true,
            'profile' => 'testing',
            'profile_options' => ['b', 'a'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        # Need to figure out how to mock up authselect check before this works
        # it { is_expected.to have_exec_resource_count(1) }
        it { is_expected.to contain_package('authselect').with_ensure('present') }
        # it { pp catalogue.resources }
        it { is_expected.to contain_exec('authselect set profile=testing features=[a, b]').with({
          unless: 'authselect check'
        }) }
      end

      context 'yes package, yes profile, creating a custom profile' do
        before(:each) do
          os_facts[:authselect_profile] = 'minimal'
        end

        let(:params) do
          {
            'package_manage' => true,
            'profile_manage' => true,
            'profile' => 'custom/testing',
            'custom_profiles' => {
              'testing' => {
                'base_profile' => 'sssd',
              }
            }
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(1) }
        # Need to figure out how to mock up authselect check before this works
        # it { is_expected.to have_exec_resource_count(1) }
        it { is_expected.to contain_package('authselect').with_ensure('present') }
        it { is_expected.to contain_exec('authselect set profile=custom/testing features=[]').with({
          command: 'authselect select custom/testing  --force'
        }) }
        it { is_expected.to contain_exec('authselect create-profile -b sssd testing').with({
          creates: '/etc/authselect/custom/testing'
        }) }
      end
    end
  end
end
