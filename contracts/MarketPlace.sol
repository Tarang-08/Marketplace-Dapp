pragma solidity ^0.4.24;

contract MarketPlace {
    struct Article {
        uint id;
        address seller;
        address buyer;
        string name;
        string description;
        uint price;
        string buyerName;
        uint buyerAge;
        bool isSold;
    }

    mapping(uint => Article) public articles;
    uint public articleCounter;

    function sellArticle(string _name, string _description, uint _price) public {
        articleCounter++;
        articles[articleCounter] = Article(
            articleCounter,
            msg.sender,
            0x0,
            _name,
            _description,
            _price,
            "",
            0,
            false
        );
    }

function getArticlesForSale() public view returns (uint[]) {
    uint[] memory ids = new uint[](articleCounter);
    uint counter = 0;
    for (uint i = 1; i <= articleCounter; i++) {
        if (articles[i].seller != address(0)) { // ✅ NEW SAFETY CHECK
            if (articles[i].buyer == 0x0 && !articles[i].isSold && articles[i].price > 0) {
                ids[counter] = i;
                counter++;
            }
        }
    }

        uint[] memory forSale = new uint[](counter);
        for (uint j = 0; j < counter; j++) {
            forSale[j] = ids[j];
        }
        return forSale;
    }

    function buyArticle(uint _id, string _buyerName, uint _buyerAge) public payable {
        Article storage article = articles[_id];
        require(article.id > 0 && article.id <= articleCounter);
        require(article.buyer == 0x0);
        require(!article.isSold);
        require(msg.sender != article.seller);
        require(msg.value == article.price);

        article.buyer = msg.sender;
        article.buyerName = _buyerName;
        article.buyerAge = _buyerAge;
        article.isSold = true;
        article.seller.transfer(msg.value);
    }

    function removeArticle(uint _id) public {
        require(articles[_id].seller == msg.sender);
        require(articles[_id].buyer == 0x0);
        delete articles[_id];
    }

    function markAsSold(uint _id) public {
        require(articles[_id].seller == msg.sender, "Only seller can mark as sold.");
        require(articles[_id].buyer == 0x0, "Already sold via buy.");
        articles[_id].isSold = true;
    }
    function getSellerArticles(address _seller) public view returns (uint[] memory) {
    uint[] memory ids = new uint[](articleCounter);
    uint counter = 0;
    for (uint i = 1; i <= articleCounter; i++) {
        if (articles[i].seller == _seller) {
            ids[counter] = i;
            counter++;
        }
    }

    uint[] memory result = new uint[](counter);
    for (uint j = 0; j < counter; j++) {
        result[j] = ids[j];
    }
    return result;
}

}