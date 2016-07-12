[ ] Page title definition happens inside blog_engine.rb. Should happen within
    page_controller.rb as a Private or Protected method.
[ ] Can I reduce the number of downcase calls by doing it to the whole path at 
    the beginning?
[ ] Add integration tests to ensure each page type loads with 200, and redirects 
    work
[ ] Consider creating a class to handle all filesystem work and better document 
    conventions. rename baron_engine to routing
[ ] Add letsencrypt free SSL support to rakefile tasks
[ ] Add comments