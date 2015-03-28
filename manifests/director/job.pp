# Classe que implementa os arquivos de jobs
define bacula::director::job (
   $name = '',
   $client = '',
   $fileset = '', 
   $jobdefs = '',

   $template = 'bacula/jobs.conf.erb',
   $file = "/etc/bacula/bacula-dir.d/job_${name}.conf",

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
