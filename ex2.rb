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
require_relative 'concordance_builder'

begin
	puts "========= EX2 Starting ========"
	dirname = ARGV[0]
	con = ConcordanceBuilder.bulid dirname
	return if con.empty?

	mysql = Mysql2::Client.new(host:"localhost", username:"ruby", password:"rubymmuze", database:"ruby_exercise")

	run_stm = mysql.prepare("insert into runs(dirname, rundate, totals) values(?,NOW(),?);")
	run_stm.execute dirname, con.count
	run_id = mysql.last_id

	term_stm = mysql.prepare("insert into concordance(run_id,term,hit_count,variations) values(?,?,?,?);")
	con.each do |k,v|
		term_stm.execute run_id, k, v.count, v.variations.join(',')
	end
	puts "Finish inserting into db with run_id #{run_id}"

rescue StandardError => e
	puts "Error in EX2: #{e.message}"
	puts e.backtrace[0]
	puts e.backtrace[1]
ensure
	puts "========= EX2 ended ========"
end
