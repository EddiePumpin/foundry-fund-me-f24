// msg.sender is person calling the fundMe test which the owner is the FundMeTest contract because it deployed the FundMe contract{Us calling the FundMeTest which now deploys the FundMe contract} us -> FundMeTest -> FundMe
// When you are running a test and you don't spacify the chain. Anvil will automatically spin up a node and delete it after the test

// What can we do to work with addresses outside our systems?
// 1. Unit - Tesing a specific part of our code
// 2. Integration - Testing how our code works with other parts of our code
// 3. Forked - Tesing our code on a simulated real environment. This can be considered as a Umit/Integration test.
// 4. Staging - Testing our code in a real environment that is not prod

// It is good to have some test before you start refactoring
