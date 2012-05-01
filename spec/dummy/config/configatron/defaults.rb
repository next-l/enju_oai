# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
# 
#   configatron.file.storage = :s3

configatron.enju.web_hostname = 'localhost'
configatron.enju.web_port_number = 3000

# パトロンの名前を入力する際、姓を先に表示する
configatron.family_name_first = true

configatron.max_number_of_results = 500
configatron.write_search_log_to_file = true
configatron.csv_charset_conversion = true

# Choose a locale from 'ca', 'de', 'fr', 'jp', 'uk', 'us'
#AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
configatron.amazon.aws_hostname = 'ecs.amazonaws.jp'
configatron.amazon.hostname = 'www.amazon.co.jp'

# :google, :amazon
configatron.book_jacket.source = :google

# :mozshot, :simpleapi, :heartrails, :thumbalizr
configatron.screenshot.generator = :mozshot
