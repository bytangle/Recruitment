// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Recruitment Contract
 * @author Edicha Joshua <mredichaj>
 * @notice Recruitment contract for posting a job and applicants applying for it
 * Note: This is just experimental. The jobs are stored on the blockchain which is an anti-pattern because blockchain
 * should not be used as database. Job postings must be stored off-chain, only some of the recruitment
 * processes should be handled by smart contracts
 */
contract Recruitment {
  
  address recruiter; // deployer's address
  
  /* Applicant data structure */
  struct Applicant {
    string[] qualifications;
    string email;
    string[] skills;
    uint[] jobs;
  }
  
  /* Job data structure */
  struct Job {
    string title;
    string[] requirements;
  }
  
  /* map applicants addresses to Applicant data */
  mapping(address => Applicant) applicants;
  Job[] public jobs; // stores jobs

  /// @dev emit when an applicant apply for a job
  /// @param jobId index of job
  /// @param applicantAddr address of the applicant
  event JobApplication(uint jobId, address applicantAddr);

  /// @dev emit when a new applicant register
  event NewApplicant(address applicant);

  /// @dev throws on unauthorized function calls
  /// @param msg description
  error Unauthorized(string msg);
  
  /**
   * @dev Gate keeper :) - only recruiter can use the function guarded by this modifier 
   */
  modifier onlyRecruiter {
    if(msg.sender != recruiter) 
      revert Unauthorized("Only the recruiter can call this function");
    _; // execute code guided by this modifier
  }

  /**
   * @dev Only applicants can use functions guarded by this modifier
   */
  modifier onlyApplicant {
    if(bytes(applicants[msg.sender].email).length > 0) 
      revert Unauthorized("Only applicants can call this function");
    _;
  }
  
  /** 
   * @dev Checks if Job exists
   * @param jobIndex index of job
   */
  modifier jobExists(uint jobIndex) {
    require(jobIndex < jobs.length);
    _; // execute code guided by this modifier
  }
  
  /* Constructor */
  constructor() {
    recruiter = msg.sender; // Whoever deployed this contract is the recruiter
  }
  
  /** 
   * @notice Post new job
   * @dev only recruiter can post jobs
   * @param title the title of the job [string]
   * @param requirements array of requirements for the job [array of string]
   */
  function postAJob(string memory title, string[] memory requirements) public onlyRecruiter {
    Job memory job = Job(title, requirements);
    jobs.push(job);
  }
  
  /** 
   * @notice Register as an applicant [any one can register]
   * @param email applicant email
   * @param qualifications string array of applicant's qualifications
   * @param skills string array of applicant's skills
   */
  function newApplicant(string memory email, string[] memory qualifications, string[] memory skills) public {
    applicants[msg.sender].email = email;
    applicants[msg.sender].qualifications = qualifications;
    applicants[msg.sender].skills = skills;

    emit NewApplicant(msg.sender); // emit event
  }
  
  /** 
   * @notice apply for a job
   * @param job index of job
   */
  function applyForAJob(uint job) public onlyApplicant jobExists(job) {
    applicants[msg.sender].jobs.push(job);

    emit JobApplication(job, msg.sender); // emit event
  }
  
  /**
   * @notice Get titles of the jobs applied for.
   * @dev can only be used by applicants
   */
  function getAppliedJobs() public onlyApplicant view returns (string[] memory) {
    uint totalJobs = applicants[msg.sender].jobs.length;

    string[] memory jobTitles = new string[](totalJobs);

    for(uint job = 0; job < totalJobs; job++) {
      jobTitles[job] = jobs[applicants[msg.sender].jobs[job]].title;
    }
    
    return jobTitles;
  }
  
  /** And more functions */
}