## Contributing

Pull Requests are welcome!

### Setup

~~~bash
git clone git@github.com:hstove/rbtc_arbitrage.git
cd rbtc_arbitrage
bundle install
~~~

To automatically run tests as you code, run `guard`.

### Adding an exchange

Create a new file called `lib/rbtc_arbitrage/clients/[exchange]_client.rb`. If the exchange is Bitstamp, the file will be `bitstamp_client.rb`.

Copy and paste this [template client](https://github.com/hstove/rbtc_arbitrage/blob/master/lib/rbtc_arbitrage/clients/client.rb.example) into your new file and replace class ExchangeClient with your exchange name. For Bitstamp, this would be **BitstampClient**.

Go through each method and implement it. You should use an already built and tested Ruby library for calling API methods. This part requires some programming and Ruby knowledge, so I won't go too into details about how to implement these methods. Feel free to look at the [other clients](https://github.com/hstove/rbtc_arbitrage/tree/master/lib/rbtc_arbitrage/clients) to see how they're done.

**Testing**

Once you've done that, create a new spec file in [spec/clients/](https://github.com/hstove/rbtc_arbitrage/tree/master/spec/clients) for your new trader. If you're a 'test first' type of developer like me, you might want to finish this step first.

While you're writing code, run guard in your terminal. This will run tests automatically as you edit code.

To test out your client, you'll first need to run `git add .`. You only need to do this one time after creating new files.

Then to test the new exchange in the command line, run rake install and then whatever command you'd like, such as:

~~~
rbtc --buyer mynewexchange
~~~

You'll need to re-run `rake install` anytime you make changes to your code and want to test the command line again.

### Submitting

When you're confident that your new exchange is fully functional, you just need to [submit a pull request](https://help.github.com/articles/using-pull-requests).

First, visit [rbtc_arbtirage](https://github.com/hstove/rbtc_arbitrage) and click the 'fork' button in the top-right. This will clone the repository in a new one under your account.

Then locate the ssh clone url on the right-hand side of your new repository. Copy that url, and in your terminal, run:

`git remote add github [url-you-just-copied]`

Then, push to that repository.

~~~
git add .
git commit -m 'added mynewexchange'
git push github master
~~~

Then go back to your repository on github. You should see a button that says 'Compare and pull request'. Click that button and enter a few details about your new code, then submit the pull request.

Your contributions are extremely thanked.