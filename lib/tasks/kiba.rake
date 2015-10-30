namespace :etl do
  task :order do
    etl_filename = 'etl/order.etl'
    script_content = IO.read(etl_filename)
    # pass etl_filename to line numbers on errors
    job_definition = Kiba.parse(script_content, etl_filename)
    Kiba.run(job_definition)
  end
end