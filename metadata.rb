name             'projects_foreman_development'
maintainer       'Ares'
maintainer_email 'ar3s.cz@gmail.com'
license          'All rights reserved'
description      'Installs/Configures foreman and related projects from git'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.16'

depends 'projects', '>= 0.4.7'
depends 'projects_tmunix', '>= 0.1.1'
depends 'nginx'
depends 'libvirt'
depends 'ca'
