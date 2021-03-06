# Classe para setar arquivos filesets
define bacula::director::client (
   $name = '',
   $address = '',
   $password = '',
   $fdport = '9102',
   $fileretention = '30 days',
   $jobretention = '6 months',
   $autoprune = 'yes',

   $template = 'bacula/clients.conf.erb',
   $file = "/etc/bacula/bacula-dir.d/client_${name}.conf",

   $db_backend = $bacula::db_backend,
   $dir_server = $bacula::director_server,
   $dir_password = $bacula::director_password,
   ) {

     # var commons for bacula complement
     $x = split($dir_server, '[.]')
     $dir_name = $x[0]

     $db_package = $db_backend ? {
       'mysql'  => $bacula::config::director_mysql_package,
       'sqlite' => $bacula::config::director_sqlite_package,
     }

     $db_service = $bacula::config::director_service
     
     #var for this #class 
     $catalog = "${dir_name}:${db_backend}"

     #
     file { $file:
       ensure  => file,
       owner   => 'bacula',
       group   => 'bacula',
       content => template($template),
       require => Package[$db_package],
       notify  => Service['bacula-director'],
       }
  }
