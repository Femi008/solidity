// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    mapping(uint256 => address) internal _ownerOf;
    mapping(address => uint256) internal _balanceOf;

    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");
        _ownerOf[id] = to;
        _balanceOf[to]++;
        emit Transfer(address(0), to, id);
    }

    function ownerOf(uint256 id) external view returns (address) {
        return _ownerOf[id];
    }
}

contract AkukiNFT is ERC721 {
    address public owner;
    uint256 public totalSupply;
    uint256 public maxSupply = 10000;

    // ✅ Mint price set in gwei (50,000,000 gwei = 0.05 ether)
    uint256 public mintPrice = 0 gwei;

    string public baseURI;

    event Minted(address indexed to, uint256 indexed tokenId);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "token doesn't exist");
        return string(abi.encodePacked(baseURI, uint2str(tokenId), ".json"));
    }

    // ✅ Payable mint using gwei-based price
    function mint() external payable {
        require(totalSupply < maxSupply, "sold out");
        require(msg.value >= mintPrice, "not enough ETH");

        uint256 tokenId = totalSupply + 1;
        totalSupply = tokenId;

        _mint(msg.sender, tokenId);
        emit Minted(msg.sender, tokenId);
    }

    // ✅ Owner mint (free)
    function ownerMint(address to) external onlyOwner {
        require(totalSupply < maxSupply, "sold out");
        uint256 tokenId = totalSupply + 1;
        totalSupply = tokenId;
        _mint(to, tokenId);
        emit Minted(to, tokenId);
    }

    // ✅ Withdraw balance
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }
}
