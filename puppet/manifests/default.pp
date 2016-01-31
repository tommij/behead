node "default" {
  class { 'apt':
    update => {
      frequency => 'daily',
    },
  } ->
  package { ["php5-cli", "git", "curl" ,"pkg-php-tools", "wget"] :
    ensure => latest,
  }
  exec { "composer-installer-fetch":  
    command => "/usr/bin/wget https://getcomposer.org/installer -O /tmp/composer_installer",
    creates => "/tmp/composer_installer",
    require => Package['wget'],
  }
  exec { "composer-install":  
    command => "/usr/bin/php /tmp/composer_installer --install-dir=/usr/local/bin --filename=composer",
    environment => "COMPOSER_HOME=/usr/local/bin",
    creates => "/usr/local/bin/composer",
    require => [Package["php5-cli"], Package["git"],Exec["composer-installer-fetch"]],
  }
  file { "behat-dir": 
    path => "/home/vagrant/behat",
    owner => "vagrant",
    group => "vagrant", 
    ensure => directory,
  }
  exec { "behat-install":  
    command => "/usr/local/bin/composer require --dev behat/behat=~3.0.4",
    user => "vagrant",
    environment => "COMPOSER_HOME=/usr/local/bin",
    cwd => "/home/vagrant/behat",
    require => [Exec["composer-install"], File["behat-dir"]],
    creates => "/home/vagrant/behat/vendor/behat/behat/bin",
  }
}
