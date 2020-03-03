# Rubycritic

The rubycritic gem let's us generate nice code quality metrics.

Use the following on the command-line. It's so explicit to avoid choking on the templates in `lib/generators`. Unfortunately couldn't get a rake task to work.

    rubycritic app lib/{*.rb,devise,financials,imports,inventory,invoices,jobs,maps,metrics,orders,p*,search,util}
