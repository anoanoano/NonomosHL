App = {
  web3Provider: null,
  contracts: {},

    //beginning of app code
  init: function() {
    // here you can load content through js before connecting to web3

    return App.initWeb3();
  },

  initWeb3: function() {

    // if (window.ethereum) {
    //     window.web3 = new Web3(window.ethereum);
    //     window.ethereum.enable();
    //     return true;
    //   }

    // metamask and mist inject their own web3 instances, so just
    // set the provider if it exists


    //test insertion
    ethereum.enable();
    if (typeof web3 !== "undefined") {
  //end

      App.web3Provider = web3.currentProvider;


        // window.addEventListener('load', () => {
        //     if (typeof web3 !== 'undefined') {
        //         web3 = new Web3(web3.currentProvider);
        //     } else {
        //         console.log('No web3? You should consider trying MetaMask!');
        //         web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
        //     }
        // });




//get network part
        web3.version.getNetwork((err, netId) => {
          web3.eth.getAccounts(function(error, accounts) {
            if (error) {
              console.log(error);
            }

            console.log('this stage');
            ethereum.enable();
            console.log('this stage 2');

            //reload page when account changes.

              // Time to reload your interface with accounts[0]!
              // console.log('reload');
              // App.reload();

            //end reload page function

            var account = accounts[0];
            console.log("account is "+account);

          switch (netId) {
            case "1":
              console.log('This is mainnet')
              $('#networkInfo').html("network: Ethereum mainnet //"+" account: "+account);
              break
            case "2":
              console.log('This is the deprecated Morden test network.')
              $('#networkInfo').html("You are connected to Morden. Connect to Rinkeby to use the app.");
              break
            case "3":
              console.log('This is the ropsten test network.')
              $('#networkInfo').html("network: ropsten //"+" account: "+account);
              break
            case "4":
              console.log('This is the rinkeby test network.')
              $('#networkInfo').html("network: rinkeby //"+" account: "+account);
              break
            case "5":
              console.log('This is the kovan test network.')
              $('#networkInfo').html("Kovan is deprecated, please connect to Rinkeby. //"+" kovan account: "+account);
                break
            default:
              console.log('This is an unknown network.')
              $('#networkInfo').html("Activate Metamask and connect to the Rinkeby Testnet to use the app.");
              var vidID = "hXrZ5Ek52ko";
              var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
              document.getElementById(1).src = embedLink;
            }
          });
        });
    } else {
      // set the provider you want from Web3.providers
      //App.web3Provider = new web3.providers.HttpProvider("http://127.0.0.1:7545");
      //web3 = new Web3(App.web3Provider);
      $('#networkInfo').html("Activate Metamask and connect to the Rinkeby Testnet to use the app.");
      var vidID = "hXrZ5Ek52ko";
      var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
      document.getElementById(1).src = embedLink;
  };
//end get network part

    window.ethereum.on('accountsChanged', function (accounts) {
      App.initWeb3();
      App.initContract();

    });


//the old good code
    // if (typeof web3 !== "undefined") {
    //   App.web3Provider = web3.currentProvider;
    //   web3 = new Web3(web3.currentProvider);
    //
    //   web3.version.getNetwork((err, netId) => {
    //     web3.eth.getAccounts(function(error, accounts) {
    //       if (error) {
    //         console.log(error);
    //       }
    //
    //       var account = accounts[0];
    //
    //     switch (netId) {
    //       case "1":
    //         console.log('This is mainnet')
    //         $('#networkInfo').html("You are connected to Mainnet. Connect to Rinkeby to use the app.");
    //         break
    //       case "2":
    //         console.log('This is the deprecated Morden test network.')
    //         $('#networkInfo').html("You are connected to Morden. Connect to Rinkeby to use the app.");
    //         break
    //       case "3":
    //         console.log('This is the ropsten test network.')
    //         $('#networkInfo').html("You are connected to Roptsen. Connect to Rinkeby to use the app.");
    //         break
    //       case "4":
    //         console.log('This is the rinkeby test network.')
    //         $('#networkInfo').html("network: rinkeby //"+" account: "+account);
    //         break
    //       case "5":
    //         console.log('This is the kovan test network.')
    //         $('#networkInfo').html("Kovan is deprecated, please connect to Rinkeby. //"+" kovan account: "+account);
    //           break
    //       default:
    //         console.log('This is an unknown network.')
    //         $('#networkInfo').html("Activate Metamask and connect to the Rinkeby Testnet to use the app.");
    //         var vidID = "hXrZ5Ek52ko";
    //         var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
    //         document.getElementById(1).src = embedLink;
    //     }
    //   });
    //   });
    // } else {
    //   // set the provider you want from Web3.providers
    //   //App.web3Provider = new web3.providers.HttpProvider("http://127.0.0.1:7545");
    //   //web3 = new Web3(App.web3Provider);
    //   $('#networkInfo').html("Activate Metamask and connect to the Rinkeby Testnet to use the app.");
    //   var vidID = "hXrZ5Ek52ko";
    //   var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
    //   document.getElementById(1).src = embedLink;
    // }
  //end the good code

    return App.initContract();

  },

  initContract: function() {

    //var abi = require('~/sl-ungovern/node-modules/ethereumjs-abi');
    //var BN = require('../node-modules/bn.js');

    $.getJSON('ERC721HarbergerLicense.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      var HLArtifact = data;
      //console.log(data);
      App.contracts.ERC721HarbergerLicense = TruffleContract(HLArtifact);

      // Set the provider for our contract.
      App.contracts.ERC721HarbergerLicense.setProvider(App.web3Provider);

      console.log(App.contracts);
      console.log('web3 provider ERC721HarbergerLicense', App.web3Provider);

        //pull the real vids from chain
      App.updateAllVidsInfo();

    });

    // $.getJSON('VCG_operator.json', function(data) {
    //   // Get the necessary contract artifact file and instantiate it with truffle-contract.
    //   var VCGArtifact = data;
    //   //console.log(data);
    //   App.contracts.VCG_operator = TruffleContract(VCGArtifact);
    //
    //   // Set the provider for our contract.
    //   App.contracts.VCG_operator.setProvider(App.web3Provider);
    //
    //   console.log(App.contracts);
    //   console.log('web3 provider VCG', App.web3Provider);
    //
    //   // App.contracts.VCG_operator.electorateCreated().watch(function(err, result) {
    //   //     console.log("action group found...");
    //   //
    //   //   });
    //
    //
    //   // App.contracts.VCG_operator.deployed().then(function(instance) {
    //   //
    //   //   console.log("Action Group Creation Watcher");
    //   //   instance.electorateCreated().watch(function(err, result) {
    //   //     console.log("action group found...");
    //   //
    //   //   });
    //   // });
    // });

    return App.bindEvents();
  },

  bindEvents: function() {
      //JustSavannah functions
        //mint functions
    $(document).on('click', '#testbtn', App.handleCreatePanel);
    $(document).on('click', '#channelChangeBtn', App.handleChannelChange);
    $(document).on('click', '#mintToken', App.handleMint);
        //infofunctions
    $(document).on('click', '#acquisitionPriceBtn', App.handleGetSimplePrice);
    $(document).on('click', '#toggleVidInfo', App.toggleVidInfo);
    $(document).on('click', '#tokenIDGetterBtn', App.handleTokenOwnerGetter);
    $(document).on('click', '#toggleDetailedInfo', App.showHideInfoTable);
    $(document).on('click', '#toggleDetailedInfo', App.handleToggleDetailedInfo);
    $(document).on('click', '#functionsBar', App.toggleNav);
    $(document).on('click', '#questionsBar', App.toggleNav2);
        //money functions
    $(document).on('click', '#acquireBtn', App.handleAcquire);
    $(document).on('click', '#revalueToken', App.handleRevalue);
    $(document).on('click', '#payTax', App.handlePayTax);
    $(document).on('click', '#assessTax', App.handleAssessTax);
    $(document).on('click', '#seizeToken', App.handleSeizeToken);
        //video functions
    $(document).on('click', '#getVideoID', App.handleGetVideoID);
    $(document).on('click', '#refreshVid', App.handleGetVideoIDAndRefreshFromChain);
    $(document).on('click', '#refreshAllVids', App.updateAllVidsInfo);
    $(document).on('keyup', '#tokenIDGetter', App.highlightVideo);
    $(document).on('keyup', '#tokenIDGetter', App.moveSideNav);
    // $(document).on('keyup', '#tokenIDGetter', App.toggleVidOverlay2);


      //make task
    $(document).on('click', '.btn-task', App.handleCreateTask);
    $(document).on('click', '#acceptTaskButton', App.handleAcceptTask);
    $(document).on('click', '#completeTaskButton', App.handleCompleteTask);
      //make job
    $(document).on('click', '.btn-job', App.handleCreateJob);
      //make electorate/panel
    $(document).on('click', '.btn-panel', App.handleCreatePanel);
    $(document).on('click', '.btn-addto-panel', App.handleAddToPanel);
    $(document).on('click', '.btn-close-panel', App.handleClosePanel);
      //make proposal
    $(document).on('click', '.btn-submit-proposal', App.handleCreateProposal);
      //make bid
    $(document).on('click', '.btn-submit-bid', App.handleHashedBidSubmitter);
      //reveal bid
    $(document).on('click', '.btn-reveal-bid', App.handleRevealBid);
      //getters
    $(document).on('keyup', '#taskID', App.handleTaskGetter);
    $(document).on('keyup', '#jobID', App.handleJobGetter);
    $(document).on('keyup', '#jobID', App.handleJobTasksGetter);
    $(document).on('keyup', '#panelID', App.handlePanelGetter);
    $(document).on('keyup', '#panelID', App.handlePanelVotersGetter);
    $(document).on('keyup', '#panelID', App.handleProposalsByPanelGetter);
    $(document).on('keyup', '#panelID', App.handleUnhideProposals);
    $(document).on('keyup', '#proposalID', App.handleProposalGetter);
    $(document).on('click', '.btn-get-userinfo', App.handleUserInfoGetter);
    $(document).on('click', '#activateConsole', App.handleUserInfoGetter);
    // $(document).on('keyup', '#proposalID', App.handlePanelGetter);
    // $(document).on('keyup', '#proposalID', App.handlePanelVotersGetter);
      //deposit
    $(document).on('click', '.btn-deposit-tocontract', App.handleDeposit);
      //withdraw
    $(document).on('click', '.btn-withdraw', App.handleWithdrawal);

  },

//JustSavannah Functions
handleChannelChange: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }

    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();
    var vidID = $('#YTVidID').val();

    console.log("print Vid ID/Token ID "+tokenID);

    // $('#proposalPanelID').html("something");
    console.log("function happening 1");

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

        console.log("function happening 2");

        instance.ownerOf(tokenID).then(function(result) {

              console.log(result);
              var owner = $('#tokenIDOwnerAddress').html(result);

              if (result == account) {
                console.log("right owner");

                var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
                console.log("print embedLink "+embedLink);
                document.getElementById(tokenID).src = embedLink;

                return instance.changeVideo(tokenID, vidID);



              } else {
                console.log("wrong owner");
              }

        }).catch(function(err) {
          console.log(err.message);
        });
      }).catch(function(err) {
        console.log(err.message);
    });
  });
},

handleMint: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("mint function 1");
    var to = accounts[0];
    var tokenID = $('#tokenID').val();
    var turnoverRate = $('#turnoverRate').val();
    var harlicValue = $('#harlicValue').val();
    var publicEquity = 0;
    var feeBeneficiary = $('#feeBeneficiary').val();
    var tokenURI = $('#tokenURI').val();
    var videoID = $('#videoID').val();

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {
      console.log("mint function 2");
      return instance.publicMint(to,
                                  tokenID,
                                  turnoverRate * 100,
                                  harlicValue * 1000,
                                  publicEquity,
                                  feeBeneficiary,
                                  tokenURI,
                                  videoID,
                                  {from: to});


    }).catch(function(err) {
      console.log(err.message);
    });
  });
},

handleAcquire: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("mint function 1");
    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();
    var price = $('#acquisitionPrice').val();
    var numPrice = parseInt(price);

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {
      console.log("mint functionality");
      console.log("and the price is: "+price);
      console.log("and the price is num: "+numPrice);

      instance.simplePrice(tokenID).then(function(result) {

            console.log(result);
            console.log(result[0].toNumber());
            console.log(result[1].toNumber());
            console.log(result[2].toNumber());
            console.log(result[3].toNumber());

            var val = result[3].toNumber();
            // var display = ("#text_"+tokenID);
            // console.log(display);
            // $(display).html(result);

            console.log("and the price is num: "+val);

            return instance.acquireToken(tokenID,
                                        {from: account,
                                        value: val});


      }).catch(function(err) {
        console.log(err.message);

    }).catch(function(err) {
      console.log(err.message);
    });
  });
  });
},

handlePayTax: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("payTax function 1");
    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();
    // var price = $('#acquisitionPrice').val();
    // var numPrice = parseInt(price);

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {
      console.log("tax log");

      instance.taxlogs(tokenID).then(function(result) {

            console.log(result);
            console.log(result[0].toNumber());
            console.log(result[1].toNumber());
            console.log(result[2].toNumber());
            console.log(result[3].toNumber());
            console.log(result[4].toNumber());
            console.log(result[5].toNumber());
            console.log(result[6].toNumber());

            var taxes = result[2].toNumber();
            var paid = result[1].toNumber();
            var unpaid = (taxes-paid);
            // var display = ("#text_"+tokenID);
            // console.log(display);
            // $(display).html(result);

            console.log("unpaid taxes: "+unpaid);

            return instance.payTax(tokenID,
                                        {from: account,
                                        value: unpaid}); // not working!!


      }).catch(function(err) {
        console.log(err.message);

    }).catch(function(err) {
      console.log(err.message);
    });
  });
  });
},

handleAssessTax: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("revalue function 1");
    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      instance.assessTax(tokenID).then(function(result) {

            console.log("tax assessed: "+result);

    }).catch(function(err) {
      console.log(err.message);
    });
  });
  });
},

handleSeizeToken: function() {
  //event.preventDefault();

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("revalue function 1");
    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();

    App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      instance.confiscateToken(tokenID).then(function(result) {

            console.log("tax assessed: "+result);

    }).catch(function(err) {
      console.log(err.message);
    });
  });
  });
},

handleRevalue: function() {
  //event.preventDefault();
  var newVal = $('#tokenNewValue').val() * 1000;
  var val = $('#tokenNewValue').html();
  if (newVal > 0) {

  web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    console.log("revalue function 1");
    var account = accounts[0];
    var tokenID = $('#tokenIDGetter').val();


        App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

          instance.selfAssess(tokenID, newVal).then(function(result) {

            console.log("revaluation: "+result);

          }).catch(function(err) {
            console.log(err.message);
      });
    });
  });
  } else {
    console.log("error: must enter a value greater than zero when you revalue");
  };
},


  //JustSavannah Getters
handleTokenOwnerGetter: function() {
  //event.preventDefault();
  var tokenID = $('#tokenIDGetter').val();

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.ownerOf(tokenID).then(function(result) {

            console.log(result);

            $('#tokenIDOwnerAddress').html(result);
            var display = ("#text_"+tokenID);
            console.log(display);
            $(display).html(result);
            $('#ownerAddressInfo').html(result);

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleAutomatedTokenOwnerGetter: function(x) {
  //event.preventDefault();
  var tokenID = x;

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.ownerOf(tokenID).then(function(result) {

            console.log(result);

            $('#tokenIDOwnerAddress').html(result);
            var display = ("#text_"+tokenID);
            console.log(display);
            $(display).html("Token ID: "+x+"<br/>"+"Owner: "+result+"<br/>");

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleGetVideoIDAutomated: function(x) {
  //event.preventDefault();
  var tokenID = x;

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.allTokensIndex(tokenID).then(function(result) {

            console.log("struct index "+result);

            instance.harlics(result).then(function(result) {

                  var display = ("#text_"+tokenID);
                  console.log(display);
                  $(display).append("Video ID: "+result[6]+"<br/>");

            }).catch(function(err) {
              console.log(err.message);
            });

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleGetSimplePriceAutomated: function(x) {
  //event.preventDefault();
  var tokenID = x;

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.simplePrice(tokenID).then(function(result) {

            console.log(result[3].toNumber());

            //$('#acquisitionPrice').html(result[3].toNumber());
            // var display = ("#text_"+tokenID);
            // console.log(display);
            // $(display).html(result);
            var display = ("#text_"+tokenID);
            console.log(display);
            $(display).append("Price (ether): "+result[3].toNumber()/1000000000000000000+"<br/>");

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleGetVideoIDAndRefreshFromChain: function(x) {
  //event.preventDefault();
  var tokenIDField = $('#tokenIDGetter').val();
  if (tokenIDField !== "") {
    var tokenID = $('#tokenIDGetter').val();
  } else {
    tokenID = x;
  }

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.allTokensIndex(tokenID).then(function(result) {

            console.log("struct index "+result);

            instance.harlics(result).then(function(result) {

                  console.log("harlic "+result[6]);
                  var vidID = result[6];
                  App.changeVideoTo(tokenID, vidID);

            }).catch(function(err) {
              console.log(err.message);
            });

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleToggleDetailedInfo: function(x) {
  //event.preventDefault();
  var tokenID = $('#tokenIDGetter').val();
  App.handleGetSimplePrice();
  App.handleTokenOwnerGetter(tokenID);

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.allTokensIndex(tokenID).then(function(result) {

            console.log("struct index "+result);
            var index = result;

            instance.harlics(index).then(function(result) {

                  console.log("harlic "+result);
                  $('#TokenIDDisplay').html(result[0].toNumber());
                  $('#TokenValue').html(result[2].toNumber()/1000);
                  $('#TaxesOwed').html(result[3].toNumber() / 1000000000000000000+" ether");
                  $('#VideoID').html(result[6]);
                  $('#FeeBeneficiary').html(result[5]);
                  $('#AcquisitionsCounterInfo').html(result[4].toNumber());
                  $('#BaseTaxRate').html(result[1].toNumber()/100+"% per year");

                  var acquisitions = result[4].toNumber();
                  var baseRate = result[1].toNumber();
                  var baseVal = result[2].toNumber();

                  instance.taxlogs(index).then(function(taxlog) {

                        console.log("taxlog "+taxlog);
                        var dateCreated = new Date(taxlog[4].toNumber()*1000);
                        var dateAssessed = new Date(taxlog[3].toNumber()*1000);

                        $('#PresentTaxRate').html((taxlog[6].toNumber()*60*60*24*365/1000000000000000000)+" ether per year "+"(or "+(taxlog[6].toNumber()/1000000000000000000)+" ether per second)").show();
                        $('#Created').html(dateCreated).show();
                        $('#LastAssessment').html(dateAssessed).show();
                        $('#IncurredTaxes').html(taxlog[2].toNumber()/1000000000000000000+" ether").show();
                        $('#PaidTaxes').html(taxlog[1].toNumber()/1000000000000000000+" ether").show();

                        var nextPerSecond = (baseVal * (baseRate / 100) * (1-(1/(acquisitions+1))));
                        $('#NextTaxRate').html("approximately "+(nextPerSecond / 100000)+" ether per year");


                  }).catch(function(err) {
                    console.log(err.message);
                  });

            }).catch(function(err) {
              console.log(err.message);
            });

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

showHideInfoTable: function() {
    var x = document.getElementById("infoTable");
    if (x.style.display === "none") {
        $('#infoTable').show();
        $('#toggleDetailedInfo').html("Hide Detailed Token Info");
    } else {
        x.style.display = "none";
        $('#toggleDetailedInfo').html("Get Detailed Token Info");
    }
},

//eventually deletable predecessor functions
handleGetVideoID: function(x) {
  //event.preventDefault();
  var tokenID = $('#tokenIDGetter').val();

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.allTokensIndex(tokenID).then(function(result) {

            console.log("struct index "+result);

            instance.harlics(result).then(function(result) {

                  console.log("harlic "+result[6]);

            }).catch(function(err) {
              console.log(err.message);
            });

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},

handleGetSimplePrice: function() {
  //event.preventDefault();
  var tokenID = $('#tokenIDGetter').val();

  App.contracts.ERC721HarbergerLicense.deployed().then(function(instance) {

      console.log("token getter 1");

      instance.simplePrice(tokenID).then(function(result) {

            console.log(result+"getPriceCalled");
            console.log(result[0].toNumber());
            console.log(result[1].toNumber());
            console.log(result[2].toNumber());
            console.log(result[3].toNumber());

            //$(display).append("Price (ether): "+result[3].toNumber()/1000000000000000000+"<br/>");
            $('#Valminusbacktax').html(result[3].toNumber()/1000000000000000000);
            // var display = ("#text_"+tokenID);
            // console.log(display);
            // $(display).html(result);

      }).catch(function(err) {
        console.log(err.message);
      });
    }).catch(function(err) {
      console.log(err.message);
  });
},


updateAllVidsInfo: function() {
  console.log("updateAllVids function called");

  for (i = 1; i <= 16; i++) {
    App.handleGetVideoIDAndRefreshFromChain(i);
  };

},

changeVideoTo: function(tokenID, vidID) {
  var embedLink = ("https://www.youtube.com/embed/"+vidID+"?autoplay=1&mute=1&loop=1&modestbranding=1&playlist="+vidID);
  console.log("print embedLink "+embedLink);
  console.log("print token, vid: "+tokenID+" "+vidID)
  document.getElementById(tokenID).src = embedLink;

},

highlightVideo: function() {
  for (i = 1; i <= 16; i++) {
    document.getElementById(i).style = "border: none";

  };
  var tokenID = $('#tokenIDGetter').val();
  // if (8 < tokenID < 17) {
  //   document.getElementById(tokenID).style = "border: 7px solid #5f4b8b";
  // } else {
    document.getElementById(tokenID).style = "border: 7px solid White; filter: hue-rotate(180deg)";
  // }
},

showInfoTable: function() {
  $('#infoTable').show();
},

toggleVidInfo: function() {
  console.log("vidInfo function called");
  var x = $('#text_1').html();
  //showVidInfo();
  console.log(x);
  if (x == "Hidden Text") {
    //$('#text_1').html("Showing Text");
    for (i = 1; i <= 16; i++) {
      App.handleAutomatedTokenOwnerGetter(i);
      App.handleGetVideoIDAutomated(i);
      App.handleGetSimplePriceAutomated(i);
    };
    App.showVidInfo();
  } else {
    App.hideVidInfo();
    $('#text_1').html("Hidden Text");
  }
},

showVidInfo: function() {
  console.log("vidInfo function called");
  $('.vidoverlay').show();
},

hideVidInfo: function() {
  console.log("vidInfo function called");
  $('.vidoverlay').hide();
},

// toggleVidOverlay2: function() {
//   console.log("vidoverlay2 function called");
//   //var tokenID = $('#tokenIDGetter').val();
//   if (($('#tokenIDGetter').val() != 16) || ($('#tokenIDGetter').val() < 1))  {
//     App.hideVidOverlay2();
//     console.log("empty token ID");
//   } else {
//     App.hideVidOverlay2();
//     App.showVidOverlay2();
//     console.log("nonempty token ID");
//   }
// },
//
// showVidOverlay2: function() {
//   var tokenID = $('#tokenIDGetter').val();
//   var num = parseInt(tokenID)+parseInt(16);
//   console.log(num);
//   $("#"+num).show();
// },
//
// hideVidOverlay2: function(i) {
//   console.log("vidInfo function called");
//   $('.vidoverlay2').hide();
// },

//TaskSupervisor Functions
  handleCreateTask: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.supervisor.deployed().then(function(instance) {

        var taskDescription = $('#taskDescription').val();
        var bondAmount = parseInt($('#bondAmount').val());
        var maxPayAmount = parseInt($('#maxPayAmount').val());
        var timeLimit = parseInt($('#timeLimit').val());
        var jobID = parseInt($('#taskJobID').val());

        console.log(taskDescription)
        console.log(bondAmount)
        console.log(maxPayAmount)
        console.log(timeLimit)

        return instance.createTask(taskDescription,
                                       jobID,
                                       bondAmount,
                                       maxPayAmount,
                                       timeLimit,
                                       false,
                                      {value: (maxPayAmount*1000000000000000),
                                      gas: 4000000})



        }).catch(function(err) {
          console.log(err.message);
      });
    });
  },


  toggleNav: function() {
    var x = document.getElementById("selectorRightsidenav");
      if (x.style.width < "25%") {
        App.closeNav2();
        App.openNav();
      } else {
        App.closeNav();
      }

  },

  openNav: function() {
      //document.getElementById("selectorSidenav").style.width = "25%";
      document.getElementById("selectorRightsidenav").style.width = "33%";

  },

  closeNav: function() {
      //document.getElementById("selectorSidenav").style.width = "0";
      document.getElementById("selectorRightsidenav").style.width = "0";

  },

  toggleNav2: function() {
    var x = document.getElementById("selectorRightsidenav2");
      if (x.style.width < "25%") {
        App.closeNav();
        App.openNav2();
      } else {
        App.closeNav2();
      }

  },

  openNav2: function() {
      //document.getElementById("selectorSidenav").style.width = "25%";
      document.getElementById("selectorRightsidenav2").style.width = "33%";

  },

  closeNav2: function() {
      //document.getElementById("selectorSidenav").style.width = "0";
      document.getElementById("selectorRightsidenav2").style.width = "0";

  },

  moveSideNav: function() {
    //document.getElementsByClassName("rightsidenav").style.width = "10%";
    var tokenID = $('#tokenIDGetter').val();
    if (tokenID < 9) {
      document.getElementById("selectorRightsidenav2").style.left = "";
      document.getElementById("selectorRightsidenav").style.left = "";
      document.getElementById("selectorRightsidenav2").style.right = "0";
      document.getElementById("selectorRightsidenav").style.right = "0";
    } else if (tokenID > 16) {
      document.getElementById("selectorRightsidenav2").style.left = "";
      document.getElementById("selectorRightsidenav").style.left = "";
      document.getElementById("selectorRightsidenav2").style.right = "0";
      document.getElementById("selectorRightsidenav").style.right = "0";
    } else if (tokenID >= 9) {
      document.getElementById("selectorRightsidenav2").style.right = "";
      document.getElementById("selectorRightsidenav").style.right = "";
      document.getElementById("selectorRightsidenav2").style.left = "0";
      document.getElementById("selectorRightsidenav").style.left = "0";
    }
  },


  ////////

  handleTaskGetter: function() {
    //event.preventDefault();

    var taskID = parseInt($('#taskID').val());
    var testVar;
    App.contracts.supervisor.deployed().then(function(instance) {

        //console.log("get task:", instance.taskListGetter(taskID));
        console.log("tasks have been run");

        instance.taskList(taskID).then(function(result) {

              testVar = result;

              console.log(result);
              console.log("Job Poster: "+testVar[0]);
              console.log("Task Description: "+testVar[1]);
              console.log("Job Number: "+testVar[2].toNumber());
              console.log("Time Posted: "+testVar[3].toNumber());
              console.log("Bond Amount: "+testVar[4].toNumber());
              console.log("Max Pay Amount: "+testVar[5].toNumber());
              console.log("Time Limit (hours): "+testVar[6].toNumber());
              $('#taskDescriptionDisplay').html("Task Description: "+testVar[1]);
              $('#bondAmountDisplay').html("Required Bond (MilliEther): "+(testVar[4]/1000000000000000));
              $('#maxPayAmountDisplay').html("Pay (MilliEther): "+testVar[5]/1000000000000000);
              $('#taskAcceptorAddress').html(testVar[11]);
              $('#jobIDDisplay').html("Job ID (Taskset): "+testVar[2]);
              $('#taskCompleteDisplay').html("Task Turned In: "+testVar[9]);
                //time manipulation
                postedTimestamp = testVar[3];
                var date = new Date(postedTimestamp*1000);
              $('#timePostedDisplay').html("Time Posted: "+date);
                timeLimit = new Number(testVar[6]);
                date.setHours(date.getHours()+(timeLimit));
              $('#timeLimitDisplay').html("Time Expires: "+date);
              //set background color green because no error
              $('#taskID').css('background-color', '#ABEBC6');


        }).catch(function(err) {
          console.log(err.message);
          $('#taskID').css('background-color', '#F1948A');
        });
      }).catch(function(err) {
        console.log(err.message);
    });
  },

  handleAcceptTask: function() {
    //event.preventDefault();

    var taskInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.supervisor.deployed().then(function(instance) {

        var taskID = parseInt($('#taskID').val());
        //var bondAmount = parseInt($('#bondAmount').val());
        console.log("accept task function called");

        instance.taskList(taskID).then(function(result) {
          var bondAmount = result[4].toNumber();
          console.log("bond = "+bondAmount);
          return instance.acceptTask(taskID,
                                        {value: (bondAmount),
                                        from: account,
                                        gas: 4000000});

        });
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleCompleteTask: function() {
    //event.preventDefault();

    var taskInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.supervisor.deployed().then(function(instance) {

        var taskID = parseInt($('#taskID').val());
        //var bondAmount = parseInt($('#bondAmount').val());
        console.log("complete task function called");

        instance.taskList(taskID).then(function(result) {

          return instance.markTaskComplete(taskID,
                                        {from: account,
                                        gas: 4000000});

        });
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleCreateJob: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      console.log("job create step 1");
      App.contracts.supervisor.deployed().then(function(instance) {
        console.log("job create step 2");
        var jobDescription = $('#jobDescription').val();
        var jobID = parseInt($('#jobID').val());

        instance.createJob(jobDescription,
                                      {from: account,
                                        gas: 4000000});
        console.log("job create step 3");
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleJobGetter: function() {
    //event.preventDefault();
    var jobID = parseInt($('#jobID').val());

    App.contracts.supervisor.deployed().then(function(instance) {

        console.log("jobs have been run");

        instance.jobList(jobID).then(function(result) {

              console.log("full result "+result);
              console.log("Job Poster: "+result[0]);
              console.log("Task Description: "+result[1]);
              console.log("Job Posted: "+result[2]);
              $('#jobDescriptionDisplay').html("Job Description: "+result[1]);
              $('#jobCreatorAddress').html(result[0]);
              $('#jobID').css('background-color', '#ABEBC6');


        }).catch(function(err) {
          console.log(err.message);
          $('#jobID').css('background-color', '#F1948A');
        });

      }).catch(function(err) {
        console.log(err.message);
    });
  },

  handleJobTasksGetter: function() {
    //event.preventDefault();
    var jobID = parseInt($('#jobID').val());

    App.contracts.supervisor.deployed().then(function(instance) {

        console.log("job tasks have been run");

          instance.jobTasklistGetter(jobID).then(function(list) {

                //console.log(result);
                //the logging of tasks to jobs either here or in the js is crashing the nonces
                var tasksInJob = "";
                console.log("jobtask logged");
                console.log(list);
                for (i = 0; i < list.length; i++) {
                  console.log(list[i].toNumber());
                  tasksInJob += (list[i].toNumber()+' ');
                }
                console.log(tasksInJob);
                $('#jobTasksDisplay').html("Tasks in this Job: "+tasksInJob);

        });

      }).catch(function(err) {
        console.log(err.message);
    });
  },

  ///////// VCG FUNCTIONS BELOW /////////////

  handleCreatePanel: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var panelName = $('#input1').val();
      $('#testtext').val(panelName);
      var account = accounts[0];
      console.log("the write function at level 1");
      App.contracts.VCG_operator.deployed().then(function(instance) {

        console.log("the write function did not throw");

        return instance.createElectorate(panelName,
                                        false, //change this, make owned electorate possible
                                        {from: account}).then(function(result) {
          // result is an object with the following values:
          //
          // result.tx      => transaction hash, string
          // result.logs    => array of decoded events that were triggered within this transaction
          // result.receipt => transaction receipt object, which includes gas used

          // We can loop through result.logs to see if we triggered the Transfer event.
          console.log("entering log parse function");
          console.log("log tx: "+result.tx);
          console.log("log event: "+result.logs[0].args.electorateID);
          var panelID = result.logs[0].args.electorateID;
          var name = result.logs[0].args.electorateName;
          console.log(panelID+" "+name);
      //$('#groupIDDisplay').html("WRITE DOWN THIS NUMBER! '"+panelID+"' is the Group ID for your Action Group, '"+name+"'. It is the Group's sole unique identifier. You will need that number (i.e., not the Group's name) to select and interact with the Group (below).");
          // for (var i = 0; i < result.logs.length; i++) {
          //   var log = result.logs[i];
          //   console.log("log = "+log);
          //   if (log.event == "electorateCreated") {
          //     console.log("found electorateCreated Event!");
          //     break;
          //   }
          // }
        }).catch(function(err) {
        console.log(err.message);
        });
    });
    });
  },

  handleAddToPanel: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      console.log("add to panel function at level 1");
      App.contracts.VCG_operator.deployed().then(function(instance) {

        var panelID = $('#panelID').val();
        console.log("add to panel function running");
        return instance.addToElectorate(panelID,
                                        account,
                                        {from: account,
                                          gas: 4000000});

      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleClosePanel: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.VCG_operator.deployed().then(function(instance) {

        var panelID = $('#panelID').val();

        return instance.closeElectorate(panelID,
                                        {from: account,
                                          gas: 4000000});

      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleCreateProposal: function() {
    //event.preventDefault();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.VCG_operator.deployed().then(function(instance) {

        var panelID = $('#proposalPanelID').val();
        var proposalDescription = $('#proposalDescription').val();
        var requiredFunding = $('#requiredFinney').val();
        var proposalBeneficiary = $('#proposalBeneficiary').val();
        var bidDeadline = $('#bidDeadline').val();
        var revealDeadline = $('#revealDeadline').val();

        return instance.createProposal(proposalDescription,
                                        requiredFunding,
                                        panelID,
                                        bidDeadline,
                                        revealDeadline,
                                        proposalBeneficiary,
                                        {from: account});

      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },



    ///VCG GETTERS///
  handlePanelGetter: function() {
    //event.preventDefault();
    var panelID = parseInt($('#panelID').val());
    $('#proposalPanelID').html("something");

    App.contracts.VCG_operator.deployed().then(function(instance) {

        console.log("panels have been run");

        instance.electorateList(panelID).then(function(result) {

              console.log(result);

              $('#panelDisplay').html("Group Name: "+result[0]);
              $('#panelCreatorAddress').html(result[3]);
              $('#panelOwnedDisplay').html("Creator-Managed Group: "+result[2]);
              $('#panelClosedDisplay').html("Group Closed: "+result[1]);
              $('#panelID').css('background-color', '#ABEBC6');

              $('#panelCreatorDisplay').html("Group Creator:");
              $('#panelMembers').html("Group Members:");

              $('#editGroupDisplay').html("EDIT GROUP:");
              $('#addMemberDisplay').html("Add Member to Selected Group:");

              $('#addressAdd').show();
              $('#addToGroupButton').show();
              $('#closeGroupButton').show();

        }).catch(function(err) {
          console.log(err.message);
          $('#panelID').css('background-color', '#F1948A');
          $('#proposalsByGroup').html("");
          $('#panelDisplay').html("No such Group.");
          $('#panelCreatorAddress').html("");
          $('#panelCreatorDisplay').html("");
          $('#panelMembers').html("");
          $('#panelOwnedDisplay').html("");
          $('#panelClosedDisplay').html("");

          $('#editGroupDisplay').html("");
          $('#addMemberDisplay').html("");

          $('#addressAdd').hide();
          $('#addToGroupButton').hide();
          $('#closeGroupButton').hide();
        });

      }).catch(function(err) {
        console.log(err.message);
    });
  },

  handlePanelVotersGetter: function() {
    //event.preventDefault();
    var panelID = parseInt($('#panelID').val());
      //custom method
    String.prototype.replaceAll = function(search, replace) {
      if (replace === undefined) {
          return this.toString();
      }
      return this.split(search).join(replace);

    };
      //usual code
    App.contracts.VCG_operator.deployed().then(function(instance) {

        console.log("voterlist getter has been run");
          //passing zero as second argument so long as its unused
        instance.electorateMemberGetter(panelID, 0).then(function(result) {

              console.log(result[0]);
              var addressString = result[0].toString();
              parsedAddressString = addressString.replaceAll(",", "\n");
              //var readableResult = stringres.replace(",", "BIGTIME");
              $('#panelMemberAddresses').html(parsedAddressString);

        }).catch(function(err) {
          console.log(err.message);
          $('#panelMemberAddresses').html("");
        });

      }).catch(function(err) {
        console.log(err.message);
        $('#panelMemberAddresses').html("");
    });
  },

  handleProposalsByPanelGetter: function() {
    //event.preventDefault();
    var panelID = parseInt($('#panelID').val());
      //custom method
    String.prototype.replaceAll = function(search, replace) {
      if (replace === undefined) {
          return this.toString();
      }
      return this.split(search).join(replace);

    };
      //usual code
    App.contracts.VCG_operator.deployed().then(function(instance) {

        console.log("voterlist getter has been run");
          //passing zero as second argument so long as its unused
        instance.panelProposalsGetter(panelID).then(function(result) {

              console.log(result);
              var proposalsString = result.toString();
              parsedProposalsString = proposalsString.replaceAll(",", ", ");
              //var readableResult = stringres.replace(",", "BIGTIME");
              $('#proposalsByGroup').html("Action Proposal IDs: "+parsedProposalsString).show();

        }).catch(function(err) {
          console.log(err.message);
          $('#proposalsByGroup').hide();
        });

      }).catch(function(err) {
        console.log(err.message);
        $('#proposalsByGroup').hide();
    });
  },


  handleProposalGetter: function() {
    //event.preventDefault();

    var proposalID = parseInt($('#proposalID').val());

    App.contracts.VCG_operator.deployed().then(function(instance) {

        console.log("proposal getter has been run");
          //passing zero as second argument so long as its unused
        instance.proposalList(proposalID).then(function(result) {

              console.log(result);
              $('#proposalDescriptionDisplay').html("Proposal Description: "+result[0]).show();
              $('#proposalPanelDisplayID').html("Group ID: "+result[1]).show();
              $('#proposalNeededFundingDisplay').html("Funding (MilliEther) Needed: "+(result[2]/1000000000000000)).show();
              $('#bidsPlacedDisplay').html("Bids Currently Submitted: "+(result[4])).show();
              $('#proposalPassedDisplay').html("Passed: "+(result[8])).show();
              $('#proposalID').css('background-color', '#ABEBC6').show();

              $('#hashBidHeader1').show();
              $('#hashBidHeader2').show();
              $('#yourBidToHash').show();
              $('#submitBidButton').show();
              $('#revealBidHeader').show();
              $('#revealBidHeader2').show();
              $('#propNumForReveal').show();
              $('#revealBidHeader3').show();
              $('#revealBid').show();
              $('#revealBidButton').show();
              //change panel ID in other box
              // $('#panelID').val(result[1]);
              //$('#panelID').keyup();
              // App.handlePanelGetter();

        }).catch(function(err) {
          console.log(err.message);
          $('#proposalID').css('background-color', '#F1948A');

          $('#proposalPanelDisplayID').html("No such proposal.");
          $('#proposalDescriptionDisplay').hide();
          $('#proposalNeededFundingDisplay').hide();
          $('#bidsPlacedDisplay').hide();
          $('#proposalPassedDisplay').hide();

          $('#hashBidHeader1').hide();
          $('#hashBidHeader2').hide();
          $('#yourBidToHash').hide();
          $('#submitBidButton').hide();
          $('#revealBidHeader').hide();
          $('#revealBidHeader2').hide();
          $('#propNumForReveal').hide();
          $('#revealBidHeader3').hide();
          $('#revealBid').hide();
          $('#revealBidButton').hide();

        });

      }).catch(function(err) {
        console.log(err.message);
    });
  },

  handleHashedBidSubmitter: function() {
    //event.preventDefault();

    var proposalID = parseInt($('#proposalID').val());
    var yourBid = parseInt($('#yourBidToHash').val());
    var secret = ("curly").toString();
    var socret = ("moe").toString();

    function leftPad (str, len, ch) {
      str = String(str);
      var i = -1;
      if (!ch && ch !== 0) ch = ' ';
      len = len - str.length;
      while (++i < len) {
        str = ch + str;
      }
      return str;
    }

    //actual hashing function
    //hash will only match solidity uint256 hash if
    //the value entered into js can be represented as uint8
    //TO DO: get a soliditySha3 library working so that you can bid with a secret-salted hash
    console.log("bidAmount = "+yourBid);
    console.log("secret = "+secret);
    var yourHashedBid = web3.sha3(leftPad((yourBid).toString(16), 64, 0), { encoding: 'hex' });
    //var experiHash = web3.sha3(leftPad((yourBid+"example").toString(16), 64, 0), { encoding: 'hex' });
    //var experiHash2 = web3.sha3(leftPad((yourBid+secret).toString(16), 64, 0), { encoding: 'hex' });
    //var experiHash3 = web3.sha3(yourBid, { encoding: 'hex' });
    //var experiHash4 = web3.sha3(leftPad((secret, socret).toString(16), 64, 0), { encoding: 'hex' });
    // var experiHash5 = web3.soliditySha3
//     var experiHash6 = soliditySHA3([ "uint256"],
//     [ 5000 ]
// ).toString('hex');
    //   [ "uint", "uint" ],
    //   [ 10000, 1448075779 ]
    // ).toString('hex');
    //console.log("vanilla:"+yourHashedBid);
    //console.log("experi:"+experiHash);
    //console.log("experi2:"+experiHash2);
    //console.log("experi3:"+experiHash3);
    //console.log("experi4:"+experiHash4);
    // console.log("experi5:"+experiHash5);
    // console.log("experi6:"+experiHash6);

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.VCG_operator.deployed().then(function(instance) {

          console.log("submitting a bid");
            //passing zero as second argument so long as its unused
          instance.conductBlindVote(proposalID,
                                yourHashedBid,
                                {from: account});
                                          //value: (bidAmount*1000000000000000),
          App.handleMakeHash(yourBid);

          }).catch(function(err) {
            console.log(err.message);
          }).catch(function(err) {
            console.log(err.message);
        });
      });
  },

  // handleHashedBidSubmitter: function() {
  //   event.preventDefault();
  //
  //   var proposalID = parseInt($('#proposalID').val());
  //   var yourBid = parseInt($('#yourBidToHash').val());
  //   var secret = $('#yourHashSecret').val();
  //
  //   function leftPad (str, len, ch) {
  //     str = String(str);
  //     var i = -1;
  //     if (!ch && ch !== 0) ch = ' ';
  //     len = len - str.length;
  //     while (++i < len) {
  //       str = ch + str;
  //     }
  //     return str;
  //   }
  //   //actual hashing function
  //   //hash will only match solidity uint256 hash if
  //   //the value entered into js can be represented as uint8
  //   console.log("bidAmount = "+yourBid);
  //   console.log("secret = "+secret);
  //   var yourHashedBid = web3.soliditySha3(yourBid);
  //   console.log(yourHashedBid);
  //
  //   web3.eth.getAccounts(function(error, accounts) {
  //     if (error) {
  //       console.log(error);
  //     }
  //     var account = accounts[0];
  //     App.contracts.VCG_operator.deployed().then(function(instance) {
  //
  //         console.log("submitting a bid");
  //           //passing zero as second argument so long as its unused
  //         instance.conductBlindVote(proposalID,
  //                               yourHashedBid,
  //                               {from: account,
  //                                         //value: (bidAmount*1000000000000000),
  //                                         gas: 4000000});
  //         App.handleMakeHash(yourBid);
  //
  //         }).catch(function(err) {
  //           console.log(err.message);
  //         }).catch(function(err) {
  //           console.log(err.message);
  //       });
  //     });
  // },

  handleRevealBid: function() {
    //event.preventDefault();

    var proposalID = parseInt($('#propNumForReveal').val());
    var revealedBid = parseInt($('#revealBid').val());

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      App.contracts.VCG_operator.deployed().then(function(instance) {

          console.log("calling RevealBid function");
            //passing zero as second argument so long as its unused
          instance.revealBid(proposalID,
                              revealedBid,
                                        {from: account,
                                          gas: 4000000});

          }).catch(function(err) {
            console.log(err.message);
          }).catch(function(err) {
            console.log(err.message);
        });
      });
  },

    // can delete
  handleMakeHash: function(bid) {
    //left pad function
    function leftPad (str, len, ch) {
      str = String(str);
      var i = -1;
      if (!ch && ch !== 0) ch = ' ';
      len = len - str.length;
      while (++i < len) {
        str = ch + str;
      }
      return str;
    }
    //actual hashing function
    //hash will only match solidity uint256 hash if
    //the value entered into js can be represented as uint8
    console.log("bidAmount = "+bid);
    var hash = web3.sha3(leftPad((bid).toString(16), 64, 0), { encoding: 'hex' })
    console.log(hash);
  },

  handleDeposit: function() {
    //event.preventDefault();

    var deposit = parseInt($('#depositAmount').val());

    console.log("depositing");

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.VCG_operator.deployed().then(function(instance) {

          console.log("submitting a bid");
            //passing zero as second argument so long as its unused
          instance.depositEtherToContract(deposit,
                                          {from: account,
                                          value: (deposit*1000000000000000),
                                          gas: 4000000});

          }).catch(function(err) {
            console.log(err.message);
          }).catch(function(err) {
            console.log(err.message);
        });
      });
  },

  handleWithdrawal: function() {
    //event.preventDefault();

    var withdrawal = parseInt($('#depositAmount').val());

    console.log("withdrawing");

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.VCG_operator.deployed().then(function(instance) {

          console.log("calling withdrawal function");
            //passing zero as second argument so long as its unused
          instance.withdrawEtherFromContract(withdrawal,
                                          {from: account,
                                          gas: 4000000});

          }).catch(function(err) {
            console.log(err.message);
          }).catch(function(err) {
            console.log(err.message);
        });
      });
  },


  ///////// USER INFO GETTERS /////////////
  handleUserInfoGetter: function() {
    //event.preventDefault();
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];

      $('#userAddress').html(account);

        App.contracts.VCG_operator.deployed().then(function(instance) {

          console.log("getter calls here");

          instance.checkEtherSentToContract(proposalID).then(function(result) {

                console.log(result);
                $('#moneyInWallet').html("Address Balance: "+(result/1000000000000000));

              instance.outstandingTax(account).then(function(result) {

                    console.log(result);
                    $('#outstandingTax').html("Outstanding Tax: "+result/1000000000000000);

                    instance.retainedTax(account).then(function(result) {

                          console.log(result);
                          $('#retainedTax').html("Received Tax: "+result/1000000000000000);

                          instance.outstandingDues(account).then(function(result) {

                                console.log(result);
                                $('#unpaidDues').html("Unpaid Dues: "+result/1000000000000000);

                                instance.paidDues(account).then(function(result) {

                                      console.log(result);
                                      $('#paidDues').html("Paid Dues: "+result/1000000000000000);

                                      instance.fundsLockedUnlessZero(account).then(function(result) {

                                            console.log("locked "+result);
                                            $('#proposalsOpen').html("Open Proposals: "+result);

                                            instance.closedProposalsGetterByAddress(account).then(function(result) {

                                                  console.log("test: "+result);
                                                  var closedProposalsString = result.toString();
                                                  console.log("test2: "+closedProposalsString);
                                                  //var parsedClosedProposalsString = closedProposalsString.replaceAll(",", ", ");
                                                  $('#proposalsClosed').html("Closed Proposals: "+closedProposalsString);


            }).catch(function(err) {
              console.log(err.message);
          }).catch(function(err) {
            console.log(err.message);
        });
      });
    });
    });
    });
    });
    });
    });
    });
  },

  handleUnhideProposals: function() {
    //event.preventDefault();

    $("#proposalBrowser").removeClass('hidden');
  },

  handleNoSuchPanel: function(event) {
    //event.preventDefault();

    $('#panelDisplay').html("No such Group.");
    $('#panelCreatorAddress').html("No such Group.");
    $('#panelOwnedDisplay').html("No such Group.");
    $('#panelClosedDisplay').html("No such Group.");
  }

  /////// divider above closing code //////////
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
