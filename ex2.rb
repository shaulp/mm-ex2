# --
# -- Table structure for table `runs`
# --

# CREATE TABLE `runs` (
#   `id` bigint(20) NOT NULL AUTO_INCREMENT,
#   `dirname` varchar(256) DEFAULT NULL,
#   `rundate` datetime DEFAULT NULL,
#   `totals` int(11) DEFAULT NULL,
#   PRIMARY KEY (`id`)
# )

# --
# -- Table structure for table `concordance`
# --

# CREATE TABLE `concordance` (
#   `id` bigint(20) NOT NULL AUTO_INCREMENT,
#   `run_id` bigint(20) DEFAULT NULL,
#   `term` varchar(100) DEFAULT NULL,
#   `hit_count` int(11) DEFAULT NULL,
#   `variations` varchar(1000) DEFAULT NULL,
#   PRIMARY KEY (`id`),
#   KEY `fk_runs` (`run_id`),
#   CONSTRAINT `fk_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`id`)
# )
#


require 'mysql2'
require_relative 'file_scanner'

begin
	puts "========= EX2 Starting ========"
	dirname = ARGV[0]
  if dirname
    mysql = Mysql2::Client.new(host:"localhost", username:"ruby", password:"rubymmuze", database:"ruby_exercise")
    FileScanner.new(mysql).run dirname
  end

rescue StandardError => e
	puts "Error in EX2: #{e.message}"
	puts e.backtrace[0]
	puts e.backtrace[1]
ensure
	puts "========= EX2 ended ========"
end
