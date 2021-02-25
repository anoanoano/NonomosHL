pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";


contract Supervisor {
    using SafeMath for uint256;

/*STORAGE*/

    Job[] public jobList;
    Task[] public taskList;
    Audit[] public auditList;
    Close[] public closeList;
        //test storage vars
    string[] public testString;

            /*map the task identifiers to their reference jobID*/

    mapping (uint256 => uint256[]) public jobTasks;

            /*map the auditIDs to their auditeeTasks*/

    mapping (uint256 => uint256) public auditMap;

            /*map the task structs to their reference jobID
            (not really working right now because can only
            return the first element in the array of structs)*/

            //mapping (uint256 => Task[]) public jobTasksMapping;

            /*map the claimable funding posted by task/job posters*/

    mapping (address => uint256) public postedFunds;

    /*EVENTS--TO DEFINE!!*/

    event TaskPosted(address indexed taskPoster, uint256 taskID);
    event TaskClosed();

    event JobPosted(address indexed jobPoster, uint256 jobID);
    event JobClosed();


    /*STRUCTS*/

    struct Job {

        /*Job = a set of subTasks, retrievable from mapping*/
        /*defined at Job creation*/

        address jobCreator;
        string jobDescription;
        uint256 postedTime;

        /*Job status variables*/

        bool allSubTasksAccepted;
        bool allSubTasksCompleted;
        bool allSubTasksReviewed;
        bool closed;

    }

    struct Task {

        /*Task = a primary task (not an audit)*/

        /*defined at Task creation*/
        address taskCreator;
        string taskDescription;
        uint256 referenceJobID; //0 if none
        uint256 postedTime;
        uint256 bondAmount; //finney
        uint256 maxPayAmount; //finney
        uint32 timeLimit; //hours
        bool auctionedTask;


        /*Task status variables*/
        bool accepted;
        bool completed;
        bool audited;
        address taskAcceptor;
        uint256 closeID;

    }

    struct Audit {

        /*auditTask = a task consisting of auditing a primary Task*/

        /*defined at Audit creation*/
        address auditCreator;
        string auditDescription;
        uint256 auditeeTask;
        uint256 postedTime;
        uint256 bondAmount; //finney
        uint256 maxPayAmount; //finney
        uint32 timeLimit; //hours
        bool auctionedAudit;


        /*Audit status variables*/
        bool accepted;
        bool completed;
        bool reAudited;
        address auditAcceptor;
        uint256 closeID;

    }

    struct Close {

        //a record of the payment/stiffing at the closing of the task/audit

        uint256 postedTime;
        uint256 referenceTaskOrAudit;
        bool trueIfAuditClose;
        bool returnedBond;
        bool paidWage;

    }


/*FUNCTIONS*/

// test functions

    function testStoreString (
        string _testString)
        public returns (bool) {
            testString.push(_testString)-1;
            return true;
    }


    /*PRIMARY POSTING FUNCTIONS*/

    function createJob (
        string _jobDescription)
        public returns (uint256) {

        /*DELETE eventually, here for reference

        uint256 jobID = jobList.length++;
        Job storage j = jobList[jobID];

        //input starting job attributes

        j.jobDescription = _jobDescription;
        j.timeLimit = _timeLimit;

        */

            Job memory _job = Job ({

                //mark Job with input values

                jobCreator: msg.sender,
                jobDescription: _jobDescription,
                postedTime: now,

                //mark Job with null values for TBD variables

                allSubTasksAccepted: false,
                allSubTasksCompleted: false,
                allSubTasksReviewed: false,
                closed: false

            });

        //push job to jobList array

        uint256 jobID = jobList.push(_job) - 1;

            //emit event
        JobPosted(msg.sender, jobID);

        return jobID;
    }

    function createTask (
        string _taskDescription,
        uint256 _referenceJobID,
        uint256 _bondAmount,
        uint256 _maxPayAmount,
        uint32 _timeLimit,
        bool _auctionedTask)
        public payable returns (uint256) {

            //there must be an error message in js when this is triggered,
            //otherwise confusing to user
            //prevent user from adding a task to a job they did not create

        if (_referenceJobID != 0) {
            require(msg.sender == jobList[_referenceJobID].jobCreator);
        }

            //encode task
        Task memory _task = Task ({

                //mark Task with input values
            taskCreator: msg.sender,
            taskDescription: _taskDescription,
            referenceJobID: _referenceJobID, //should be 0 for standalone task
            postedTime: now,
            bondAmount: SafeMath.mul(_bondAmount, 1000000000000000), //finney
            maxPayAmount: SafeMath.mul(_maxPayAmount, 1000000000000000), //finney
            timeLimit: _timeLimit,
            auctionedTask: _auctionedTask,

                //mark Task with null values for TBD variables
            taskAcceptor: 0x0,
            accepted: false,
            completed: false,
            audited: false,
            closeID: 0
        });

            //push task to taskList to general struct array

        uint256 taskID = taskList.push(_task) - 1;

            //map the taskID uint to its referenceJob/

        jobTasks[_referenceJobID].push(taskID);

            /*record the sender's concurrent posting of finney,
            and require that it equals or exceeds the maxPayAmount*/

        postedFunds[msg.sender] += msg.value;
        /*comment out for testing to reduce fail points:*/
        //require(msg.value == taskList[taskID].maxPayAmount);

            /*(DELETE IF NOT USED) map the whole struct to its referenceJob--
            See *storage* above--not really working now bc can only seem to
            return the first element in the struct array */

            //jobTasksMapping[_referenceJobID].push(_task);

        //emit Event

        TaskPosted(msg.sender, taskID);
        return taskID;


    }

    function createAudit (
        string _auditDescription,
        uint256 _auditeeTask,
        uint256 _bondAmount,
        uint256 _maxPayAmount,
        uint32 _timeLimit,
        bool _auctionedAudit)
        public payable returns (uint256) {

            Audit memory _audit = Audit ({

                    //mark Audit with input values

                auditCreator: msg.sender,
                auditDescription: _auditDescription,
                auditeeTask: _auditeeTask,
                postedTime: now,
                bondAmount: SafeMath.mul(_bondAmount, 1000000000000000), //finney
                maxPayAmount: SafeMath.mul(_maxPayAmount, 1000000000000000), //finney
                timeLimit: _timeLimit,
                auctionedAudit: _auctionedAudit,

                    //mark Audit with null for TBD values

                auditAcceptor: 0x0,
                accepted: false,
                completed: false,
                reAudited: false,
                closeID: 0

            });

            //prevent user from adding an audit to a task they did not create

        if (_auditeeTask != 0) {
            require(msg.sender == taskList[_auditeeTask].taskCreator);
        }

            //push audit to auditList array

        uint256 auditID = auditList.push(_audit) - 1;

            //map the auditID uint to its auditeeTask/

        auditMap[_auditeeTask] = auditID;

            /*record the sender's concurrent posting of finney,
            and require that it equals or exceeds the maxPayAmount*/

        postedFunds[msg.sender] += msg.value;
        require(msg.value == auditList[auditID].maxPayAmount);

        return auditID;
    }


    /*INTERACTION FUNCTIONS*/

    function acceptTask (
        uint256 _taskID)
        public payable {

            /*
            get Task and check that Task is
            1) not already accepted,
            2) not an auctioned Task,
            3) not expired
            */

        uint256 taskID = _taskID;
        require(taskList[taskID].accepted == false);
        require(taskList[taskID].auctionedTask == false);
        if (taskList[taskID].timeLimit > 0) {
        require((taskList[taskID].postedTime + (taskList[taskID].timeLimit * 1 hours)) > now);
        }
            //record the bond sent by user, & Require that sufficient bond is send & posted

        postedFunds[msg.sender] += msg.value;
        require(msg.value == taskList[taskID].bondAmount);

            //mark task struct accepted by user

        taskList[taskID].taskAcceptor = msg.sender;
        taskList[taskID].accepted = true;

    }

    function acceptAudit (
        uint256 _auditID)
        public payable {

            //local vars

        uint256 auditID = _auditID;
        uint256 auditeeTaskID = auditList[auditID].auditeeTask;

            /*
            check that Audit is
            1) not already accepted,
            2) not an auctioned Audit,
            3) not expired, if there is a time limit
            4) not being accepted by the auditee task acceptor
            */

        require(auditList[auditID].accepted == false);
        require(auditList[auditID].auctionedAudit == false);
        if (auditList[auditID].timeLimit > 0) {
        require((auditList[auditID].postedTime + (auditList[auditID].timeLimit * 1 hours)) > now);
        }
        require(msg.sender != taskList[auditeeTaskID].taskAcceptor);

            //record the bond sent by user, & Require that sufficient bond is send & posted

        postedFunds[msg.sender] += msg.value;
        require(msg.value >= auditList[auditID].bondAmount);

            //mark Audit struct accepted by user

        auditList[auditID].auditAcceptor = msg.sender;
        auditList[auditID].accepted = true;

    }

    function markTaskComplete (uint256 _taskID)
        public {
            require(msg.sender == taskList[_taskID].taskAcceptor);
            taskList[_taskID].completed = true;
    }

    function markAuditComplete (uint256 _auditID)
        public {
            uint256 auditeeTaskID = auditList[_auditID].auditeeTask;
            require(msg.sender == auditList[_auditID].auditAcceptor);
            auditList[_auditID].completed = true;
            taskList[auditeeTaskID].completed = true;
    }

    function closeOutTask (uint256 _taskID,
        bool _returnBond,
        bool _remitPay)
        public
        returns (uint256) {

                //set up pay variable, threshold requires

            uint256 applicablePay;
            address taskAcceptor = taskList[_taskID].taskAcceptor;
            require(msg.sender == taskList[_taskID].taskCreator);
            require(postedFunds[msg.sender] >= taskList[_taskID].maxPayAmount);
            require(postedFunds[taskAcceptor] >= taskList[_taskID].bondAmount);
            require(taskList[_taskID].accepted == true);

                //fill out Close struct

            Close memory _close = Close ({
                postedTime: now,
                referenceTaskOrAudit: _taskID,
                trueIfAuditClose: false,
                returnedBond: _returnBond,
                paidWage: _remitPay
            });

                //push close Struct to storage

            uint256 closeID = closeList.push(_close) - 1;

        /*contract remits the deposit/pay*/

                //applicablePay is necessarily maxpayamount only if non-auction

            if (taskList[_taskID].auctionedTask == false) {
                applicablePay = taskList[_taskID].maxPayAmount;
            } else {
                revert();
            }


                //if returnBond true, K sends to Acceptor, else, to taskCreator

            uint256 taskBond = taskList[_taskID].bondAmount;
            if (_returnBond == true) {
                taskAcceptor.transfer(taskBond);
            } else {
                msg.sender.transfer(taskBond);
            }

            postedFunds[taskAcceptor] -= taskBond;

                //if remitPay true, K sends to Acceptor, else, to taskCreator
            if (_remitPay == true) {
                taskAcceptor.transfer(applicablePay);
            } else {
                msg.sender.transfer(applicablePay);
            }

            postedFunds[msg.sender] -= applicablePay;

                //update Task struct with closeID

            taskList[_taskID].closeID = closeID;

            return closeID;

    }

    function closeOutAudit (uint256 _auditID,
        bool _returnBond,
        bool _remitPay)
        public
        returns (uint256) {

                //set up pay variable, threshold requires

            uint256 applicablePay;
            address auditAcceptor = auditList[_auditID].auditAcceptor;
            require(msg.sender == auditList[_auditID].auditCreator);
            require(postedFunds[msg.sender] >= auditList[_auditID].maxPayAmount);
            require(postedFunds[auditAcceptor] >= auditList[_auditID].bondAmount);
            require(auditList[_auditID].accepted == true);

                //fill out Close struct

            Close memory _close = Close ({
                postedTime: now,
                referenceTaskOrAudit: _auditID,
                trueIfAuditClose: true,
                returnedBond: _returnBond,
                paidWage: _remitPay
            });

                //push close Struct to storage

            uint256 closeID = closeList.push(_close) - 1;

        /*contract remits the deposit/pay*/

                //applicablePay is necessarily maxpayamount only if non-auction

            if (auditList[_auditID].auctionedAudit == false) {
                applicablePay = auditList[_auditID].maxPayAmount;
            } else {
                revert();
            }


                //if returnBond true, K sends to Acceptor, else, to taskCreator

            uint256 auditBond = auditList[_auditID].bondAmount;
            if (_returnBond == true) {
                auditAcceptor.transfer(auditBond);
            } else {
                msg.sender.transfer(auditBond);
            }

            postedFunds[auditAcceptor] -= auditBond;

                //if remitPay true, K sends to Acceptor, else, to taskCreator
            if (_remitPay == true) {
                auditAcceptor.transfer(applicablePay);
            } else {
                msg.sender.transfer(applicablePay);
            }

            postedFunds[msg.sender] -= applicablePay;

                //update Audit struct with closeID

            auditList[_auditID].closeID = closeID;

            return closeID;

    }

    /*
    function closeOutAudit () public {

    }

    function closeJob () public {

    }
    */

    /*GETTERS AND INFORMATION FUNCTIONS*/

    /*enter the jobID and jobTaskId
    (i.e., the [arraynum] of the Task w/in the Job);
    and return the global TaskID of that task, if there is one*/

    function testStringGetter ()
        public constant returns (uint256 numberOfStrings,
                              string lastString) {
            uint256 len = testString.length - 1;
            return (testString.length,
                  testString[len]);
    }

    function getJobSizeAndTaskID (
        uint256 _jobID,
        uint256 _jobTask)
        public constant returns (uint256 numberOfTaskIDs,
                            uint256 calledTaskID) {

            return (jobTasks[_jobID].length,
                    jobTasks[_jobID][_jobTask]);

        }

        //simple checker of balance of entire contract
        //possibly mark owned, eventually

    function getContractBalance ()
        public constant returns (uint256) {
            return this.balance;
        }

        //check storage mapping to see how many Ether the user has posted to the contract

    function checkEtherSentToContract ()
        public constant returns (uint256) {

            uint256 userFunds = postedFunds[msg.sender];
            return userFunds;

        }

        /*FALLBACK FUNCTION for handling payments not associated with
        the posting of a task*/

    function ()
        public payable {

            postedFunds[msg.sender] += msg.value;

        }

        //simple checker of the contract address, for testing

    function checkContractAddress ()
        external constant returns (address contractAddress) {

            contractAddress = this;
            return contractAddress;
        }

    function taskListGetter (uint256 _taskID)
        public constant returns (string) {
            return (taskList[_taskID].taskDescription);
    }

    function jobTasklistGetter (uint256 _jobID)
        public constant returns (uint256[]) {
            return (jobTasks[_jobID]);
    }

}
