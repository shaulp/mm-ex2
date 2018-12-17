require 'set'
module ConcordanceBuilder

	class Term
		attr_reader :standard
		attr_reader :count

		def Term.clean word
			return nil unless word && word.is_a?(String)
			
			word = word[0..-3] if word.end_with?("'s")
			word.downcase!

			# ... more cleaning

			return word
		end

		def initialize word
			@standard = word
			@count = 0
			@variations = Set.new
		end

		def add variation = nil
			@count += 1
			@variations << variation if variation && variation != @standard
		end

		def variations
			@variations.to_a
		end

		def <=> other
			return -1 if self.count < other.count
			return 1 if self.count > other.count

			return 1 if self.standard < other.standard
			return -1 if self.standard > other.standard
			return 0
		end

	end # class Term

	class Concordance
		@@terms = Hash.new {|h,k| h[k] = Term.new(k)}

		def initialize
			throw "Concordance is static and cannot be instanciated"
		end

		def self.add_term word
			var = self.is_known_variation(word)
			@@terms[var].add(word)
		end

		def self.is_known_variation word
			# ...
			# ...
			word
		end

		def self.output out_fn
			file = File.open(out_fn, 'w')
			@@terms.values.sort{|a,b| b <=> a}.each do |term|
				file.write "#{term.standard},#{term.count}"	
				file.write ",#{term.variations}" if term.variations.any?
				file.write "\n"
			end
		end

		def self.get
			@@terms.dup
		end

		def self.count
			@@terms.count
		end
	end # class Concordance

	def self.read_and_process_file fn
		puts "Processing #{fn}..."
		num_lines = 0
		num_words = 0
		terms_before = Concordance.count

		pushover_word = nil
		File.foreach(fn).each do |line|
			num_lines += 1
			terms = line.chomp.split(/[\s,.;\(\)\[\]\{\}\+\\\$\*\?]/).delete_if(&:empty?).map {|w| Term.clean w}.compact
			next if terms.empty?

			num_words += terms.count
			if pushover_word
				num_words -= 1
				terms[0] = pushover_word+terms[0]
				puts " -- and now merged into #{terms[0]}"
			end
			pushover_word = nil

			terms[0..-2].each do |word|
				Concordance.add_term word
			end

			## Special treatment for last word in line
			if terms.last.end_with?('-')
				pushover_word = terms.last[0..-2]
				puts " -- Pushing #{terms.last} over to next line"
			else
				Concordance.add_term terms.last
			end

		end
		puts "... done. #{num_lines} line and #{num_words} words read; #{Concordance.count-terms_before} terms added."
	end

	def self.bulid dirname, outfile=nil
		puts "Looking in #{dirname}"
		Dir.glob("#{dirname}/*.txt") do |fn|
		  next if fn == '.' or fn == '..'
		  read_and_process_file fn
		end

		puts "Total of #{Concordance.count} terms found." 
		if outfile
			Concordance.output outfile
			puts "Output to #{outfile} created."
		else
			return Concordance.get
		end
			
	rescue StandardError => e
		puts "Error in ConcordanceBuilder: #{e.message}"
		puts e.backtrace[0]
		puts e.backtrace[1]
	end
end # module
