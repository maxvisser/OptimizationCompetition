pragma solidity ^0.4.24;

contract OptimizationCompetition {
    address private optimumSolutionAddress;
    int private optimumSolution;
    int[] private optimumParameters;

    uint private _bounty;
    uint private _competitionEnd;
    
    bool private _minimizeObjective;
    function objectiveFunction(int[] parameters) private pure returns(int y);
    event CompetitionEnded(int optimumSolution, int[] optimumParameters);
    event NewOptimum(int optimumSolution, int[] optimumParameters);
    
    constructor(uint competitionTime, bool minimizeObjective) public payable{
        _competitionEnd = now + competitionTime;
        _minimizeObjective = minimizeObjective;
        if (_minimizeObjective) {
            optimumSolution = int256(~((uint256(1) << 255)));//int256 maximum value
        } else {
            optimumSolution = int256((uint256(1) << 255));//int256 minimum value
        }
        _bounty = msg.value;
    }
    
    function runCandidateSolution(int[] parameters) public {
        require(now < _competitionEnd);
        int candidateSolution = objectiveFunction(parameters);
        bool newOptimum = false;
        if (_minimizeObjective) {
            if (candidateSolution < optimumSolution) {
                newOptimum = true;
            }
        } else {
            if (candidateSolution > optimumSolution) {
                newOptimum = true;
            }
        }
        if (newOptimum) {
            optimumSolution = candidateSolution;
            optimumSolutionAddress = msg.sender;
            optimumParameters = parameters;
            emit NewOptimum(optimumSolution, optimumParameters);
        }
    }
    
    function claimBounty() public {
        if (now >= _competitionEnd && msg.sender == optimumSolutionAddress) {
            emit CompetitionEnded(optimumSolution, optimumParameters);
            selfdestruct(msg.sender);
        }
    }
}

contract SimpleTestCompetition is OptimizationCompetition(500, true) {
    function objectiveFunction(int[] parameters) private pure returns(int y) {
        require(parameters.length == 1);
        //y = (x - 1)^2
        //optimum: x = 1
        return (parameters[0] - 1) * (parameters[0] - 1);
    }
}
