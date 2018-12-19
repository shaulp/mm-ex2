require_relative 'concordance_builder'

class FileScanner

  def initialize db
    @db = db
  end
  def run dirname
    con = ConcordanceBuilder.bulid dirname
    return if con.empty?

    run_stm = @db.prepare("insert into runs(dirname, rundate, totals) values(?,NOW(),?);")
    run_stm.execute dirname, con.count
    run_id = @db.last_id

    term_stm = @db.prepare("insert into concordance(run_id,term,hit_count,variations) values(?,?,?,?);")
    con.each do |k,v|
      term_stm.execute run_id, k, v.count, v.variations.join(',')
    end
    puts "Finish inserting into db with run_id #{run_id}"
  end
end