# Nonomos

Private property, reinvented...

1. This is an illustration of a novel private property scheme called Harberger taxation.

Based on the ideas of economists Henry George, Arnold Harberger, and Glen Weyl, Harberger taxation is designed to reduce monopoly rents and inefficient speculative behavior. If implemented in the real world, it could be the basis of a more just, equal, and efficient economy. This project is a "sandbox" and a bridge to broader implementation in cryptocurrency ecosystems and beyond.

2. OK, how does this work?

Your "property" in this scheme is a unique Ethereum (ERC-721) token, entitling you to control one of the 16 video panels. To possess a Token, you have to pay property tax. This is calculated as a percentage of the Token's declared value. But you get to to declare yourself what the Token (i.e., your control of a video panel) is worth.
What's the catch--why not just declare low values? Because the value you declare is also a public sell offer. If someone pays you that amount, you must give them your property.

3. How do I find out which Token ID corresponds to which panel?

The Tokens are numbered 1-16. Click the "info" icon at the top left of the screen to see the Token ID numbers.

4. Start interacting with the tokens by buying one.

(You'll need Metamask to do this.) Use the console to select a token, see its price, tax rate, and other relevant data, and buy it.

When you own a Token, you can control the video that apears on the corresponding panel on this site.

You do this by selecing the Token in the console and submitting a new YouTube video ID (found at the end of every YouTube URL). You can also reassess its value, and pay taxes you owe on the Token.

5. How are taxes calculated?

When it was created, each token was assigned a base tax rate. The first few owners of each token, however, pay less than that base rate. As the token changes hands more times, it approaches this rate asymptotically (current rate = (1 - (base rate/number of times the token has been purchased)). When you click "detailed info" on the console you can see each token's current tax rate and the rate that you will pay after you have acquired it. This pattern reflects the idea of "decaying artificial capital" and gives early adopters a heightened incentive to drive the platform's value.

6. How are taxes collected?

The amount of back taxes owed by Token possessors are tracked continually, assessed each second. A Token owner may pay taxes to zero out her back taxes. Or, she may simply not pay taxes. But when a new owner buys the Token from her, she will receive only the price of the Token minus the back taxes she owes.

Furthermore, if her back taxes grow to exceed one Ether,the value of her Token will be automatically reset to zero, allowing anyone else to snap it up. So don't let your back taxes accumulate!

7. Where does the tax money go?

On the Rinkeby testnet, the fake ether collected via tax on Tokens 1-16 (i.e., the videos) goes to Nonomos.  It's TBD how tax revenues will be handled on mainnet. In an ideal Harberger tax ecosystem, the taxes would actually be divided up and sent directly back to you--i.e., visitors of this website--to compensate you for the fact that your eyeballs make this ecosystem more valuable. This reflects a thought-provoking insight known as the Henry George Theorem. But to do that here, we'd need to verify your identity, which is beyond the scope of the demo at this point.

Remember, too, that if you use our smart contract to mint your own Harberger license Tokens (i.e., Tokens numbered higher than 16), you can set the tax beneficiary yourself, thus plugging the taxation system into whatever institutional architecture you please.  See below.

8. Can I do anything else with these Tokens?

Yep. You can mint your very own. Token IDs 1-16 are taken for the 16 video panels here. But IDs 17-infinity, as of this writing, do not exist.  You can easily mint them on nonomos.com under the info panel. Choose a unique number (the transaction will fail if your preferred Token ID has already been taken), fill in the rest of the info (if there is a field that you don't need, like video ID, it doesn't matter, just put any string of letters/numbers), and click Mint Token. The unique ERC-721 token is now held by the account you used to mint it. You can interact with it on this site, or if you know what you're doing, any other Ethereum client. Write a real-world contract that entitles the holder to of your Token to use a real-world asset. Experiment!
