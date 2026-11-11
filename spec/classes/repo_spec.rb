# frozen_string_literal: true

require 'spec_helper'

describe 'mongodb::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe 'without parameters' do
        it { is_expected.to raise_error(Puppet::Error, %r{required}) }
      end

      describe 'with version set' do
        let :params do
          {
            version: '5.0',
          }
        end

        case facts[:os]['family']
        when 'RedHat'
          it { is_expected.to contain_class('mongodb::repo::yum') }

          it do
            is_expected.to contain_yumrepo('mongodb')
              .with_baseurl('https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/5.0/$basearch/')
          end
        when 'Suse'
          it { is_expected.to contain_class('mongodb::repo::zypper') }

          it do
            is_expected.to contain_zypprepo('mongodb')
              .with_baseurl('https://repo.mongodb.org/zypper/suse/$releasever_major/mongodb-org/5.0/$basearch/')
          end
        when 'Debian'
          it { is_expected.to contain_class('mongodb::repo::apt') }

          case facts[:os]['name']
          when 'Debian'
            it do
              is_expected.to contain_apt__source('mongodb')
                .with_location('https://repo.mongodb.org/apt/debian')
                .with_release("#{facts[:os]['distro']['codename']}/mongodb-org/5.0")
            end
          when 'Ubuntu'
            it do
              is_expected.to contain_apt__source('mongodb')
                .with_location('https://repo.mongodb.org/apt/ubuntu')
                .with_release("#{facts[:os]['distro']['codename']}/mongodb-org/5.0")
            end
          end
        else
          it { is_expected.to raise_error(Puppet::Error, %r{not supported}) }
        end
      end

      describe 'with version 8.0', if: facts[:os]['family'] == 'Debian' do
        let :params do
          {
            version: '8.0',
          }
        end

        it do
          is_expected.to contain_apt__source('mongodb')
            .with_key('dir' => '/usr/share/keyrings/', 'name' => 'mongodb-server-8.0.asc', 'source' => 'https://www.mongodb.org/static/pgp/server-8.0.asc')
        end
      end

      describe 'with version 9.0', if: facts[:os]['family'] == 'Debian' do
        let :params do
          {
            version: '9.0',
          }
        end

        it do
          is_expected.to contain_apt__source('mongodb')
            .with_key('dir' => '/usr/share/keyrings/', 'name' => 'mongodb-server-9.asc', 'source' => 'https://www.mongodb.org/static/pgp/server-9.asc')
        end
      end

      describe 'with proxy' do
        let :params do
          {
            version: '5.0',
            proxy: 'http://proxy-server:8080',
            proxy_username: 'proxyuser1',
            proxy_password: 'proxypassword1',
          }
        end

        case facts[:os]['family']
        when 'RedHat'
          it { is_expected.to contain_class('mongodb::repo::yum') }

          it do
            is_expected.to contain_yumrepo('mongodb')
              .with_enabled('1')
              .with_proxy('http://proxy-server:8080')
              .with_proxy_username('proxyuser1')
              .with_proxy_password('proxypassword1')
          end
        when 'Suse'
          it { is_expected.to contain_class('mongodb::repo::zypper') }
        when 'Debian'
          it { is_expected.to contain_class('mongodb::repo::apt') }
        else
          it { is_expected.to raise_error(Puppet::Error, %r{not supported}) }
        end
      end
    end
  end
end
