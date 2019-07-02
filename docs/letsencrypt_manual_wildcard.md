# Updating the wildcard certs

Because we are using a wildcard cert we [cannot use Heroku's own automated
cert renewal](https://devcenter.heroku.com/articles/automated-certificate-management#providing-your-own-tls-certificate).

Our DNS provider is [DNSMadeEasy](https://cp.dnsmadeeasy.com/login), get the
credentials from Weston or Rob.

Can see all certs, their expiries, and learn their heroku names with:

    heroku certs -a localorbit-staging

There are [docs for the DNSMadeEasy letencrypt api options](https://github.com/Neilpang/acme.sh/tree/dev/dnsapi#9-use-dnsmadeeasy-domain-api), but you can just follow the specific instructions below.

## To update staging certs

If it's the first run on your machine you need to setup these environment vars:

    export ME_Key="API key from dnsmadeeasy"
    export ME_Secret="Secret key from dnsmadeeasy"

then you can reissue the certs:

    acme.sh --issue --dns dns_me -d next.localorbit.com -d '*.next.localorbit.com'

and update heroku with the new certs:

    heroku certs:update ~/.acme.sh/next.localorbit.com/ca.cer ~/.acme.sh/next.localorbit.com/next.localorbit.com.cer ~/.acme.sh/next.localorbit.com/next.localorbit.com.key -a localorbit-staging

Once you've run the acme.sh command above once the `ME_Key` and `ME_Secret` will get saved to your
`~/.acme.sh/account.conf` and should not need to be set again.

## To update production certs

    acme.sh --issue --dns dns_me -d '*.localorbit.com'

    heroku certs:update '~/.acme.sh/*.localorbit.com/ca.cer' '~/.acme.sh/*.localorbit.com/*.localorbit.com.cer' '~/.acme.sh/*.localorbit.com/*.localorbit.com.key' -a localorbit-production
