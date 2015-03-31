# Classe que implementa os arquivos de jobs
define bacula::director::jobs (
   $jobdefs = '',
   $clients = ['teste','teste2'],
   ) {
      each($clients) |$value| {  notify {"Running with $value": } }


     }


