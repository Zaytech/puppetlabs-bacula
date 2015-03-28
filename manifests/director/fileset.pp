# Classe para setar arquivos filesets
define bacula::director::fileset (
   $name = '',
   $options = [ 'signature = MD5', 'compression = GZIP' ],
   $files = ['/home', '/root', '/etc'],
   $excludes = ['/proc', '/tmp', '/.journal', '/.jsck'],
   $db_backend = $bacula::db_backend,  
   $template = 'bacula/filesets.conf.erb',
   $file = "/etc/bacula/bacula-dir.d/filesets_${name}.conf" ) 

   {

   $db_package = $db_backend ? {
     'mysql'  => $bacula::config::director_mysql_package,
     'sqlite' => $bacula::config::director_sqlite_package,
   }

   $db_service = $bacula::config::director_service

   file { $file:
     ensure  => file,
     owner   => 'bacula',
     group   => 'bacula',
     content => template($template),
     require => Package[$db_package],
     notify  => Service['bacula-director'],
     }
  }
