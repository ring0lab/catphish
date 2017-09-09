#!/usr/bin/env ruby

# catphish - Domain Suggester
# version: 1.0.0
# author: Viet Luu
# author: Kent 'picat' Gruber
# web: www.ring0lab.com

require 'set'
require 'trollop/subcommands'
require 'resolv'
require 'simpleidn'
require 'whois-parser'
require 'rest-client'
require 'csv'
require 'nokogiri'

module Catphish

  VERSION = '1.1.0'

  # Some popular domains to use.
  POPULAR_TOP_DOMAINS = ['.com', '.co', '.net', '.org', '.info']

  # Some country domains to use.
  COUNTRY_TOP_DOMAINS = [
    ".ac", ".ad", ".ae", ".af", ".ag", ".ai", ".al", ".am", ".an", ".ao", ".aq", ".ar", ".as",
    ".at", ".au", ".aw", ".ax", ".az", ".ba", ".bb", ".bd", ".be", ".bf", ".bg", ".bh", ".bi",
    ".bj", ".bm", ".bn", ".bo", ".bq", ".br", ".bs", ".bt", ".bv", ".bw", ".by", ".bz", ".ca", 
    ".cc", ".cd", ".cf", ".cg", ".ch", ".ci", ".ck", ".cl", ".cm", ".cn", ".co", ".cr", ".cu", 
    ".cv", ".cw", ".cx", ".cy", ".cz", ".de", ".dj", ".dk", ".dm", ".do", ".dz", ".ec", ".ee",
    ".eg", ".eh", ".er", ".es", ".et", ".eu", ".fi", ".fj", ".fk", ".fm", ".fo", ".fr", ".ga", 
    ".gb", ".gd", ".ge", ".gf", ".gg", ".gh", ".gi", ".gl", ".gm", ".gn", ".gp", ".gq", ".gr", 
    ".gs", ".gt", ".gu", ".gw", ".gy", ".hk", ".hm", ".hn", ".hr", ".ht", ".hu", ".id", ".ie", 
    ".il", ".im", ".in", ".io", ".iq", ".ir", ".is", ".it", ".je", ".jm", ".jo", ".jp", ".ke", 
    ".kg", ".kh", ".ki", ".km", ".kn", ".kp", ".kr", ".kw", ".ky", ".kz", ".la", ".lb", ".lc", 
    ".li", ".lk", ".lr", ".ls", ".lt", ".lu", ".lv", ".ly", ".ma", ".mc", ".md", ".me", ".mg",
    ".mh", ".mk", ".ml", ".mm", ".mn", ".mo", ".mp", ".mq", ".mr", ".ms", ".mt", ".mu", ".mv", 
    ".mw", ".mx", ".my", ".mz", ".na", ".nc", ".ne", ".nf", ".ng", ".ni", ".nl", ".no", ".np", 
    ".nr", ".nu", ".nz", ".om", ".pa", ".pe", ".pf", ".pg", ".ph", ".pk", ".pl", ".pm", ".pn", 
    ".pr", ".ps", ".pt", ".pw", ".py", ".qa", ".re", ".ro", ".rs", ".ru", ".rw", ".sa", ".sb", 
    ".sc", ".sd", ".se", ".sg", ".sh", ".si", ".sj", ".sk", ".sl", ".sm", ".sn", ".so", ".sr", 
    ".ss", ".st", ".su", ".sv", ".sx", ".sy", ".sz", ".tc", ".td", ".tf", ".tg", ".th", ".tj", 
    ".tk", ".tl", ".tm", ".tn", ".to", ".tp", ".tr", ".tt", ".tv", ".tw", ".tz", ".ua", ".ug",
    ".uk", ".us", ".uy", ".uz", ".va", ".vc", ".ve", ".vg", ".vi", ".vn", ".vu", ".wf", ".ws", 
    ".ye", ".yt", ".za", ".zm", ".zw" ]

  # Some generic domains.
  GENERIC_DOMAINS = [
    ".academy", ".accountant", ".accountants", ".active", ".actor", ".adult", ".aero", 
    ".agency", ".airforce", ".apartments", ".app", ".archi", ".army", ".associates", 
    ".attorney", ".auction", ".audio", ".autos", ".band", ".bar", ".bargains", ".beer", 
    ".best", ".bid", ".bike", ".bingo", ".bio", ".biz", ".black", ".blackfriday", ".blog", 
    ".blue", ".boo", ".boutique", ".build", ".builders", ".business", ".buzz", ".cab", ".cam", 
    ".camera", ".camp", ".cancerresearch", ".capital", ".cards", ".care", ".career", ".careers", 
    ".cars", ".cash", ".casino", ".catering", ".center", ".ceo", ".channel", ".chat", ".cheap", 
    ".christmas", ".church", ".city", ".claims", ".cleaning", ".click", ".clinic", ".clothing", 
    ".cloud", ".club", ".coach", ".codes", ".coffee", ".college", ".community", ".company", 
    ".computer", ".condos", ".construction", ".consulting", ".contractors", ".cooking", ".cool", 
    ".coop", ".country", ".coupons", ".credit", ".creditcard", ".cricket", ".cruises", ".dad", 
    ".dance", ".date", ".dating", ".day", ".deals", ".degree", ".delivery", ".democrat", ".dental", 
    ".dentist", ".design", ".diamonds", ".diet", ".digital", ".direct", ".directory", ".discount", 
    ".dog", ".domains", ".download", ".eat", ".education", ".email", ".energy", ".engineer", 
    ".engineering", ".equipment", ".esq", ".estate", ".events", ".exchange", ".expert", ".exposed", 
    ".express", ".fail", ".faith", ".family", ".fans", ".farm", ".fashion", ".feedback", ".finance", 
    ".financial", ".fish", ".fishing", ".fit", ".fitness", ".flights", ".florist", ".flowers", ".fly", 
    ".foo", ".football", ".forsale", ".foundation", ".fund", ".furniture", ".fyi", ".gallery", ".garden", 
    ".gift", ".gifts", ".gives", ".glass", ".global", ".gold", ".golf", ".gop", ".graphics", ".green", 
    ".gripe", ".guide", ".guitars", ".guru", ".healthcare", ".help", ".here", ".hiphop", ".hiv", ".hockey", 
    ".holdings", ".holiday", ".homes", ".horse", ".host", ".hosting", ".house", ".how", ".info", ".ing", 
    ".ink", ".institute", ".insure", ".international", ".investments", ".jewelry", ".jobs", ".kim", ".kitchen", 
    ".land", ".lawyer", ".lease", ".legal", ".lgbt", ".life", ".lighting", ".limited", ".limo", ".link", 
    ".loan", ".loans", ".lol", ".lotto", ".love", ".luxe", ".luxury", ".management", ".market", ".marketing", 
    ".markets", ".mba", ".media", ".meet", ".meme", ".memorial", ".men", ".menu", ".mobi", ".moe", ".money", 
    ".mortgage", ".motorcycles", ".mov", ".movie", ".museum", ".name", ".navy", ".network", ".new", ".news", 
    ".ngo", ".ninja", ".one", ".ong", ".onl", ".online", ".ooo", ".organic", ".partners", ".parts", ".party", 
    ".pharmacy", ".photo", ".photography", ".photos", ".physio", ".pics", ".pictures", ".pid", ".pink", ".pizza", 
    ".place", ".plumbing", ".plus", ".poker", ".porn", ".post", ".press", ".pro", ".productions", ".prof", 
    ".properties", ".property", ".qpon", ".racing", ".recipes", ".red", ".rehab", ".ren", ".rent", ".rentals", 
    ".repair", ".report", ".republican", ".rest", ".review", ".reviews", ".rich", ".rip", ".rocks", ".rodeo", 
    ".rsvp", ".run", ".sale", ".school", ".science", ".services", ".sex", ".sexy", ".shoes", ".show", ".singles", 
    ".site", ".soccer", ".social", ".software", ".solar", ".solutions", ".space", ".studio", ".style", ".sucks", 
    ".supplies", ".supply", ".support", ".surf", ".surgery", ".systems", ".tattoo", ".tax", ".taxi", ".team", 
    ".store", ".tech", ".technology", ".tel", ".tennis", ".theater", ".tips", ".tires", ".today", ".tools", ".top", 
    ".tours", ".town", ".toys", ".trade", ".training", ".travel", ".university", ".vacations", ".vet", ".video", 
    ".villas", ".vision", ".vodka", ".vote", ".voting", ".voyage", ".wang", ".watch", ".webcam", ".website", ".wed", 
    ".wedding", ".whoswho", ".wiki", ".win", ".wine", ".work", ".works", ".world", ".wtf", ".xxx", ".xyz", ".yoga", ".zone"]

  # It's like a treasure map, but for chars.
  CHARS_MAP = {
    "a" => ["\u1EA1", "\u0101", "\u0203", "\u00E0", "\u00E1"], 
    "e" => ["\u1EB9", "\u0113", "\u0207", "\u00E8", "\u00E9"], 
    "c" => ["\u0107"],
    "d" => ["\u0111", "\u010F"], 
    "i" => ["\u1EC9", "\u1ECB", "\u012B", "\u00EC", "\u020B"],
    "o" => ["\u1ECD", "\u014D", "\u020F", "\u00F2", "\u00F3"], 
    "u" => ["\u1EE5", "\u016B", "\u0217", "\u00F9", "\u00FA"], 
    "r" => ["\u0155", "\u0213"],
    "t" => ["\u0165"],
    "y" => ["\u1EF7", "\u00FD"],
    "z" => ["\u017E"]
  }	

  # Current langs: Vietnamese, Croation and Czech
  CYRILLIC_CHARS_MAP = {
    "a" => "\u0430", "b" => "\u0432", "c" => "\u0441", "e" => "\u0435",
    "f" => "\u0493", "h" => "\u04BB", "i" => "\u0456", "k" => "\u043A",
    "l" => "\u04CF", "m" => "\u043C", "n" => "\u04E5", "o" => "\u043E",
    "p" => "\u0440", "r" => "\u0433", "s" => "\u0455", "t" => "\u0442",
    "u" => "\u0446", "w" => "\u0428", "x" => "\u0445", "y" => "\u0423"
  }

  # Homoglyp substitute character mappings.
  HOMOGLYPH_SUBSTITUTE_CHARACTERS = {
    "0" => "o", "1" => "l", "o" => "0", "m" => "rm", "d" => "cl",
    "g" => "q", "i" => "l", "l" => "i", "p" => "q", "cl" => "d",
    "q" => "g", "u" => "v", "v" => "u", "w" => "vv", "y" => "v"
  }

  # Create a new container, optionally in a block syntax.
  def self.new_container
    return Set.new unless block_given?
    yield Set.new
  end

  # Mirrorization method.
  def self.mirrorization(domain)
    domain = domain.split('.')[0]
    new_container do |container|
      (0...domain.size).each do |i|
        d = domain.clone
        if (i == domain.size - 2 || d[i+1] == '-')
          d[i+1] = d[i] + d[i+1]
        elsif (d[i] == '-')
          d[i] = d[i]
        elsif (d[i] == d[i+1] || d[i] == d[i-1])
          # do nothing
        else
          d[i+1] = d[i]
        end
        # names like google.com seem to trick this up
        container << ['Mirrorization',d] unless d == domain
      end
      container 
    end
  end

  # Singular or plural method.
  def self.singular_or_pluralise(domain)
    domain = domain.split('.')[0]
    new_container do |container|
      if (domain[domain.size - 1] == 's')
        container << ['SingularOrPluralise', domain.chomp(domain[domain.size - 1])]
      else
        container << ['SingularOrPluralise', domain + "s"]
      end
    end
  end

  # Prepend or append method.
  def self.prepend_or_append(domain) 
    domain = domain.split('.')[0]
    words  = ['www-', '-www', 'http-', '-https']
    new_container do |container|
      words.each do |w|
        d = domain.clone
        if (w[0] == '-')
          d = d + w
        else
          d = w + d
        end
        container << ['PrependOrAppend',d]
      end
      container
    end
  end

  # Homoglyphs method.
  def self.homoglyphs(domain)
    domain = domain.split('.')[0]
    new_container do |container|
      HOMOGLYPH_SUBSTITUTE_CHARACTERS.each do |k, v|
        next unless domain.include?(k)
        container << ['Homoglyphs', domain.sub(k, v)]
        container << ['Homoglyphs', domain.gsub(k, v)]
      end
      container << ['Homoglyphs',domain.sub('cl', 'd')]
      container << ['Homoglyphs',domain.gsub('cl', 'd')]
    end
  end
  
  # Double extensions method.
  def self.double_extensions(domain)
    new_container do |container|
      container << ['DoubleExtensions', domain.split('.')[0] + '-' +  domain.split('.')[1]]
    end
  end

  # Dash omission method.
  def self.dash_omission(domain)
    domain = domain.split('.')[0]
    new_container do |container|
      if (domain.include?('-'))
        container << ['DashOmission', domain.gsub('-', '')]
      end
      container
    end 
  end

  # Punycode method.
  def self.punycode(domain)
    domain = domain.split('.')[0]
    new_container do |container|
      @D2 = domain.clone
      CHARS_MAP.each do |k, v|
        d = domain.clone
        (0...domain.size).each do |i|
          if (d[i] == k)
            (0...v.size).each do |i2|
              d[i] = v[i2]
              @D2[i] = v[i2]
              container << ['Punycode',d, SimpleIDN.to_ascii(d)]
              d = domain.clone
            end
          end
        end

        cont = container.dup
        cont.each do |domain|
          temp_domain = []
          (0...v.size).each do |i3|
            temp_domain << (domain[1].gsub!(k, v[i3]))
            if !temp_domain[0].nil?
              container << ['Punycode',temp_domain[0], SimpleIDN.to_ascii(temp_domain[0])]
            end
          end
        end	
      end

      container << ['Punycode',@D2, SimpleIDN.to_ascii(@D2)]

      d = domain.clone
      punyValid = true
      if domain =~ /d|g|q|v|z/
        punyValid = false
      end
      CYRILLIC_CHARS_MAP.each do |k, v|
        (0...domain.size).each do |i|
          if (d[i] == k)
            d[i] = v
          end
        end
      end
      if punyValid
        container << ['Punycode',d, SimpleIDN.to_ascii(d)]
      end
      container 
    end 
  end

  # Whois information for a given domain.
  def self.whois_information(domain, extension = nil, retries = 1)
    domain = domain + extension if extension
    begin
      Whois.whois(domain + extension).parser.available?
    rescue
      retry if (retries -= 1) >= 0
    end
  end

  # IP Address information for a given domain.
  def self.resolv_information(domain, extension = nil, retries = 1)
    domain = domain + extension if extension 
    begin
      Resolv.getaddress domain
    rescue
      retry if (retries -= 1) >= 0
    end
  end

  # Checking for Expired Domains Network
  # Catphish is currently supporting Fortiguard, Juniper, and Trustwave for URL filtering check.
	# Future support: PALTO ALTO and SonicWall.
  def self.check_expired_domains(domain, check, username, password)
  	container = []
  	
  	if !check
	  	# Login 
	  	RestClient.post('https://member.expireddomains.net/login/', {login: username, password: password}) do |res|
	  		if res.headers[:location].include?("error=1")
	  			puts "Your expireddomains.net account is invalid. Please check your account again."
	  			exit 1
	  		else
	  			RestClient.get("https://member.expireddomains.net/export/search/?export=csv&falexa=1&flimit=50&fstatuscomfree=22&fstatusnetfree=22&fstatusorgfree=22&fstatusbizfree=22&fstatusinfofree=22&q=#{domain}&fprice=100&fstatususfree=22&fstatusukfree=22&fstatuscofree=22&fwhois=22
				", {Cookie: res.headers[:set_cookie].to_s.split(';')[0].slice!(2, res.headers[:set_cookie].to_s.size)}) do |res|
					CSV.parse(res.body, {:col_sep => ";"}) do |line|
						unless line[4] == "domaincc"
							container << [line[4], line[14]]
						end
					end
	  			end
	  		end
	  	end
	  	check_url_filter(container)
	  else
	  	container << [domain]
	  	check_url_filter(container)
	  end
  end

  def self.check_url_filter(container)
  	printf "%-30s %-30s %s\n\n", "Domain", "Age", "Categorize"
  	container.each do |domain|
  		printf "%-30s %-30s %s\n\n", domain[0], domain[1], "Fortiguard:" + check_fortiguard(domain[0])
  		printf "%-30s %-30s %s\n\n", '', '', "Juniper: " + check_juniper(domain[0])
  		printf "%-30s %-30s %s\n\n", '', '', "Trustwave: " + check_trustwave(domain[0])
  	end
  end

  # Check Fortiguard URL Filter
  def self.check_fortiguard(domain)
  	RestClient.get("https://fortiguard.com/webfilter?q=#{domain}") do |res|
  		return Nokogiri::HTML(res.body).at('meta[name="og:description"]')['content'].split(':')[1]
  	end
  end

  # Check Juniper URL Filter
  def self.check_juniper(domain)
  	RestClient.post("http://mtas.surfcontrol.com/mtas/Juniper-Results.php", {url: domain, submit1: 'Test Site'}) do |res|
  		if res.body.split(/categorized as \<B\>(.*?)\<BR\>/)[1] == ' '
  			return 'Unknown'
  		else 
  			return res.body.split(/categorized as \<B\>(.*?)\<BR\>/)[1]
  		end
  	end
  end

  #Check Trustwave URL Filter
  def self.check_trustwave(domain)
  	RestClient.post("https://www3.trustwave.com/support/m86filtercheck.asp", {checkurl: domain, Submit: 'Check Database'}) do |res|
  		if res.body.split(/The URL \<b\>.*\<\/b\>(.*?)\<\/p\>/)[1] == ' is not found in the database.'
  			return 'Unknown'
  		elsif res.body.include?("daily quota")
  			return 'Daily query limit exceeded'
  		else
  			return Nokogiri::HTML(res.body).css('li')[146].text
  		end
  	end
  end

  # The "main" method of sorts of the application.
  def self.start(domain_container, domain_types: POPULAR_TOP_DOMAINS, all: false, punycode: false, header: false)
    if punycode
      printf "%-30s %-30s %-30s %s\n\n", "Type", "Domain", "Punycode", "Status" if header
    else
      printf "%-30s %-30s %s\n\n", "Type", "Domain", "Status" if header
    end
    threads = []
    domain_container.each do |d|
      domain_types.each do |extension|
        threads << Thread.new do
          if punycode
            if whois_information(d[2] || d[1], extension) 
              if d[2].nil? 
                printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, "none", "\e[32mAvailable\e[0m"
              else
                printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, d[2] + extension, "\e[32mAvailable\e[0m"
              end
            elsif all
              printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, d[2], "Not Available"
            end
          else
            begin
              if Resolv.getaddress("#{d[1] + extension}") and all
                printf "%-30s %-30s %s\n", d[0], d[1] + extension, "Not Available"
              end
            rescue Exception
              if punycode
                printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, "none", "\e[32mAvailable\e[0m"
              else
                printf "%-30s %-30s %s\n", d[0], d[1] + extension, "\e[32mAvailable\e[0m"
              end 
            end
          end
        end
      end
    end  
    threads.each(&:join)
  end

  # Logos are pretty cool.
  def self.logo
    "
 ██████╗ █████╗ ████████╗██████╗ ██╗  ██╗██╗███████╗██╗  ██╗
██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██║  ██║██║██╔════╝██║  ██║
██║     ███████║   ██║   ██████╔╝███████║██║███████╗███████║
██║     ██╔══██║   ██║   ██╔═══╝ ██╔══██║██║╚════██║██╔══██║
╚██████╗██║  ██║   ██║   ██║     ██║  ██║██║███████║██║  ██║
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝
                                                    [v]#{VERSION} 
                                       Author: Mr. V & Picat 
                                           Web: ring0lab.com                                                                       
    "
  end

end

# Default to a help menu if nothing has been given.
ARGV[0] = '-h' if ARGV.empty?

Trollop::Subcommands::register_global do
  banner <<-END
#{Catphish.logo}
Usage
  #{File.basename($0)} [global options] COMMAND [command options]

COMMANDS
  generate                    Generate domains
  expired                     Find available expired domains (experimental)

Additional help
  #{File.basename($0)} COMMAND -h

Options
  END
  opt :logo, 	              "ASCII art banner", 									 type: :bool, default: true
  opt :column_header,         "Header for each column of the output",               type: :bool,     default: true
  opt :Domain,                "Target domain to analyze",                           type: :string,  required: (ARGV[0] == '-h' ? false : true)
  opt :Verbose,               "Show all domains, including non-available ones",     type: :bool,     default: false
end

Trollop::Subcommands::register_subcommand('generate') do 
  banner <<-END
#{Catphish.logo}
Usage
  #{File.basename($0)} -D [domain] generate [options]
Options
  END
  opt :type,                  "Type of level domains: (popular, country, generic)", type: :string,   default: 'popular'   
  opt :All,                   "Use all of the possible methods",                    type: :bool,     default: false
  opt :Mirrorization,         "Use the mirrorization method",                       type: :bool,     default: false
  opt :singular_or_pluralise, "Use the singular or pluralise method",               type: :bool,     default: false
  opt :prepend_or_append,     "Use the prepend or append method",                   type: :bool,     default: false
  opt :Top_level_domains,     "Use a specific ( set of ) top-level domain(s)",      type: :strings, required: false
  opt :Homoglyphs,            "Use the homoglyphs method",                          type: :bool,     default: false
  opt :double_extensions,     "Use the double extensions method",                   type: :bool,     default: false
  opt :Dash_omission,         "Use the dash omission method",                       type: :bool,     default: false
  opt :Punycode,              "Use the punycode method",                            type: :bool,     default: false
end

Trollop::Subcommands::register_subcommand('expired') do
  banner <<-END
#{Catphish.logo}
Usage
  #{File.basename($0)} -D [domain] expired [options]
  \nAn expireddomains.net account is required to check for available expired domains.\n
Options
  END
  opt :check,                  "Check category of the provided domain (No account needed)", 						  type: :bool,   default: false
  opt :username,							 "expireddomains.net Username",																	type: :string, required: false
  opt :password,							 "expireddomains.net Password", 																	type: :string, required: false
end

opts = Trollop::Subcommands::parse!

# If given top level domains, use those. Otherwise, use whatever was 
# given for the type or default to popular domains.

case opts.subcommand
when "generate"
	if opts.subcommand_options[:Top_level_domains]
	  type = Catphish.new_container do |container|
	    opts.subcommand_options[:Top_level_domains].each do |domain|
	      domain = "." + domain unless domain[0] == "."
	      container << domain
	    end
	    container
	  end
	else
	  case opts.subcommand_options[:type].downcase.to_sym
	  when :country
	    type = Catphish::COUNTRY_TOP_DOMAINS
	  when :generic 
	    type = Catphish::GENERIC_DOMAINS
	  else
	    type = Catphish::POPULAR_TOP_DOMAINS
	  end
	end

# Get all of the domains we're interested in processing.
	domains = Catphish.new_container do |container|
	  if opts.subcommand_options[:All]
	    [:Mirrorization, :singular_or_pluralise, :prepend_or_append, :Homoglyphs, :double_extensions, :Dash_omission, :Punycode].each do |opt|
	      Catphish.send(opt.to_s.downcase.to_sym, opts.global_options[:Domain]).each do |domain|
	        container << domain
	      end
	    end
	  else
	    [:Mirrorization, :singular_or_pluralise, :prepend_or_append, :Homoglyphs, :double_extensions, :Dash_omission, :Punycode].each do |opt|
	      next unless opts.subcommand_options[opt]
	      Catphish.send(opt.to_s.downcase.to_sym, opts.global_options[:Domain]).each do |domain|
	        container << domain
	      end
	    end
	  end
	  container
	end

	# If there are no domains to process, then fail.
	if domains.empty?
		puts "Nothing to process ( try other options )!"
	  exit 1
	end

# Check if punycode is going to show up to the party.
	if opts.subcommand_options[:Punycode] || opts.subcommand_options[:All]
	  puny = true
	else
	  puny = false
	end

	# Print the logo to the screen, or maybe not.
	puts Catphish.logo if opts.global_options[:logo]

	# Start the heavy logic.
	Catphish.start(domains, domain_types: type, all: opts.global_options[:Verbose], punycode: puny, header: opts.global_options[:column_header])
when "expired"
	# Print the logo to the screen, or maybe not.
	puts Catphish.logo if opts.global_options[:logo]
	# Start the heavy logic.
	if !opts.subcommand_options[:check] && (!opts.subcommand_options[:username] || !opts.subcommand_options[:password])
		puts "Error: options '--username' and '--password' need parameters for command 'expired'.
Try --help for help.
"
		exit 1
	end

	if opts.subcommand_options[:check]
		Catphish.check_expired_domains(opts.global_options[:Domain], opts.subcommand_options[:check], '', '')
	end

	if opts.subcommand_options[:username] && opts.subcommand_options[:password]
		Catphish.check_expired_domains(opts.global_options[:Domain], opts.subcommand_options[:check], opts.subcommand_options[:username], opts.subcommand_options[:password])	
	end
end