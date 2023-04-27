require 'digest'
require 'matrix'

require_relative '../helpers/openai'

SEPARATOR = "\n* "
MAX_SECTION_LEN = 500

class QuestionsController < ApplicationController
  rescue_from ActionController::BadRequest, with: :bad_request
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def get_prompt(sections, question)
    header = """Paulo Coelho is the author of the book The Alchemist, which has sold over 65 million copies worldwide. He is also a lyricist and novelist, having written many other best-selling books such as Brida, The Valkyries, and Eleven Minutes. These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Using the questions and the context given, answer the final question in this paragraph. It starts with 'Q:'. You should only respond with an answer. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Alchemist:\n"""

    question_1 = "Q: What is the message of The Alchemist?\n\nA: The Alchemist is a story about a shepherd boy named Santiago who is on a journey to find his personal legend. The message is that when you have a dream, the universe conspires to help you achieve it. If you have the courage to follow your heart, you will find your way to your destiny.\n\n"
    question_2 = "Q: You wrote The Alchemist in just two weeks. What was your writing process like?\n\nA: I had the story in my mind for many years. When I finally decided to write it, I wrote for two weeks straight, from morning until night. I didn't even stop to eat or sleep. It was a spiritual experience. The story flowed out of me effortlessly, as if it had been waiting to be told.\n\n"
    question_3 = "Q: What advice would you give to someone who wants to follow their dreams?\n\nA: My advice is to have the courage to follow your heart and listen to your intuition. The journey may not be easy, but it will be worth it. Don't be afraid of failure or making mistakes. They are all part of the journey. Believe in yourself and in the universe, and you will find your way to your destiny.\n\n"
    question_4 = "Q: The Alchemist has sold over 150 million copies worldwide. Did you ever imagine that it would become such a phenomenon?\n\nA: No, I never imagined that it would become such a phenomenon. I wrote the book for myself, as a way to explore my own spiritual journey. It's a universal story, and I think that's why it has resonated with so many people around the world.\n\n"
    question_5 = "Q: You've said that you believe in signs from the universe. Can you share an example of a sign that you've received?\n\nA: There have been many signs along my journey, but one that stands out to me is when I was walking in the streets of Amsterdam and I saw a woman with a tattoo of the cover of The Alchemist on her arm. It was a sign that the book had touched her life in some way, and it reminded me of the power of storytelling.\n\n"
    question_6 = "Q: What's next for you? Are you working on any new projects?\n\nA: I'm always working on new projects. I'm currently writing a new book called Hippie, which is based on my own experiences traveling through Europe and Asia in the 1970s. It's a love story, and it's about the search for spiritual enlightenment.\n\n"
    question_7 = "Q: You've faced many challenges in your life, including being institutionalized by your parents and facing censorship in your home country of Brazil. How have these experiences shaped you as a writer?\n\nA: These experiences have taught me the importance of perseverance and the power of storytelling. They have also taught me to be true to myself and to follow my heart, even in the face of adversity. As a writer, I feel that it's my responsibility to share my own experiences and to tell the stories of those who may not have a voice.\n\n"

    return header + sections + question_1 + question_2 + question_3 + question_4 + question_5 + question_6 + question_7 + "\n\n\nQ: #{question}" + "\n\nA: "
  end

  def create
    unless params[:question].present?
      raise ActionController::ParameterMissing.new("Missing question parameter")
    end

    if params[:question].length > 200 
      raise ActionController::BadRequest.new('Question is too long. Max characters is 200.')
    end

    q = build_valid_query(params[:question])
    md5 = Digest::MD5.hexdigest q
    embeds = get_or_hash_query_embed(q)
    ordered = order_by_similarity(embeds, formatted_embeds)

    chosen_sections = choose_sections(ordered)

    joined = chosen_sections.join(" ")
    answer = maybe_get_cached_answer(q, md5, joined)

    # I tried using resemble to create a clip, but their api kept responding with:
    # {"success"=>false, "message"=>"Sync requests are disabled for your account, contact us for help"}
    # even after I upgraded my account. Their api is also pretty slow, so I'm just going to ignore this for now.
    render json: { answer: answer }
  end

  def build_valid_query(query)
    if query.end_with?("?")
      return query
    else
      return query + "?"
    end
  end

  def vector_similarity(x, y)
    x_vec = Vector.elements(x)
    y_vec = Vector.elements(y)

    x_vec.inner_product(y_vec)
  end

  def order_by_similarity(query_embeds, doc_embeds)
    document_similarities = doc_embeds.map do |doc_index, doc_embedding|
      similarity = vector_similarity(query_embeds, doc_embedding)
      [similarity, doc_index]
    end
  
    document_similarities.sort.reverse
  end

  def get_or_hash_query_embed(q)
    md5 = Digest::MD5.hexdigest q

    # cache any subsequent question embeds in redis.
    # this obv isn't a big brain cache key but it'll do the trick.
    embeds = Rails.cache.fetch("#{md5}-E", expires_in: 12.hours) do
      Rails.logger.info "Fetching embeds for question: #{q}"

      OpenaiHelper.get_embeddings(q)
    end

    embeds
  end

  def choose_sections(ordered)
    separator_len = 3
    chosen_sections = []
    chosen_sections_len = 0

    ordered.each do |_, section_index|
      num =  pages_data[0][section_index]
      text = pages_data[1][section_index]
      tokens = pages_data[2][section_index].split(',').map(&:to_i)
      
      chosen_sections_len += tokens.length + separator_len

      if chosen_sections_len > MAX_SECTION_LEN
        chosen_sections << "#{SEPARATOR}#{text[1...(MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length)]}"
        break
      end

      chosen_sections << "#{SEPARATOR}#{text}"
    end

    chosen_sections
  end

  def maybe_get_cached_answer(q, md5, joined)
    prompt = get_prompt(joined, q)

    # cache any subsequent question embeds in redis.
    # this obv isn't a big brain cache key but it'll do the trick.
    answer = Rails.cache.fetch("#{md5}-C", expires_in: 12.hours) do
      Rails.logger.info "Fetching completion for question prompt: #{q}"

      OpenaiHelper.get_completions(prompt)
    end
  end
end