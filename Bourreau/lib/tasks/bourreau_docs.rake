
#
# CBRAIN Project
#
# Copyright (C) 2008-2012
# The Royal Institution for the Advancement of Learning
# McGill University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rdoc/task'

namespace :doc do
  desc "Create CBRAIN Bourreau documentation"
  RDoc::Task.new(:bourreau) { |rdoc|
     rdoc.rdoc_dir = 'doc/bourreau'
     rdoc.title    = "CBRAIN Bourreau API Documentation"
     rdoc.options << '-a'
     rdoc.options << '-W https://github.com/aces/cbrain/blob/master/Bourreau/%s'
     rdoc.main = 'README.md'
     rdoc.rdoc_files.include('README.md')
     rdoc.rdoc_files.include('app/*/*.rb')
     rdoc.rdoc_files.include('lib/*.rb')
     rdoc.rdoc_files.include('lib/cbrain_extensions/**/*.rb')
     rdoc.rdoc_files.include('cbrain_plugins/installed-plugins/cbrain_task/*/bourreau/*.rb')
     rdoc.rdoc_files.include('cbrain_plugins/installed-plugins/cbrain_task/*/common/*.rb')
     rdoc.rdoc_files.include('cbrain_plugins/installed-plugins/userfiles/*/*.rb')
     rdoc.rdoc_files.include('config/initializers/cbrain.rb')
     rdoc.rdoc_files.include('config/initializers/core_extensions/*.rb')
     rdoc.rdoc_files.include('config/initializers/added_core_extensions/kernel.rb')
  }
end

