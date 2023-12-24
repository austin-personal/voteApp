function submitVote() {
    const selectedOption = document.querySelector('input[name="vote"]:checked');
    
    if (selectedOption) {
        const voteValue = selectedOption.value;
        alert(`You voted for ${voteValue}`);
        // Here, you can add logic to send the vote to the backend (which we'll build next)
    } else {
        alert("Please select an option before voting.");
    }
}
