module Imdb

  class MovieList
    def movies
      @movies ||= parse_movies
    end
    
    private
    def parse_movies
      document.search('a[@href^="/title/tt"]').reject do |element|
        element.innerHTML.imdb_strip_tags.empty? ||
        element.parent.innerHTML =~ /media from/i
      end.map do |element|
        id = element['href'][/\d+/]

        title = element.parent.innerHTML
        #data = element.parent.innerHTML.split("<br />")
        #if !data[0].nil? && !data[1].nil? && data[0] =~ /img/
        #  title = data[1]
        #else
        #  title = data[0]
        #end
        
        title = title.imdb_strip_tags.imdb_unescape_html
        title.gsub!(/\s+\(\d\d\d\d\)$/, '')
        
        alternative_titles = []

        if title =~ /\saka\s/
          titles = title.split(/\saka\s/)
          title = titles.shift.strip.imdb_unescape_html
          alternative_titles = titles.map { |t| t.strip.imdb_strip_tags.imdb_unescape_html }
        end

        if ( title.include?("TV Episode")  || title.include?("TV Series"))
          type="TV"
        elsif ( title.include?("(Actor"))
          type="Actor"
        elsif ( title.include?("(Actress"))
          type="Actress"
        elsif ( title.include?("(Self"))
          type="Self"
        elsif ( title.include?("(Producer"))
          type="Producer"
        elsif ( title.include?("(Thanks"))
          type="Thanks"
        elsif ( title.include?("(Soundtrack"))
          type="Soundtrack"
        else
          type="Movie"
        end

        alternative_titles.each do |aka|
          title += ", aka '"+aka+"'"
        end

        [id, title, alternative_titles, type]
      end.uniq.map do |values|
        Imdb::Movie.new(*values)
      end
    end
  end # MovieList

end # Imdb
