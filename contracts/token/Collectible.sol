pragma solidity ^0.8.0;

    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';
    import "https://github.com/CrazyNFT/openzeppelin-contracts/blob/master/contracts/metatx/MinimalForwarder.sol";

abstract contract ERC2771Context is Context {
    address immutable _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

contract MetaTxReceiverExample is ERC2771Context {
    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {}

    function exampleFunction(uint256 amount) external {
        (bool success, ) = _msgSender().call{ value: amount }("");
        require(success, "Transfer failed.");
    }
}

contract Example is ERC721, Ownable ,MinimalForwarder{

        using Strings for uint256;

        // Optional mapping for token URIs
        mapping (uint256 => string) private _tokenURIs;

        // Base URI
        string private _baseURIextended;


        constructor(string memory _name, string memory _symbol)
            ERC721(_name, _symbol)
        {}

        function setBaseURI(string memory baseURI_) external onlyOwner() {
            _baseURIextended = baseURI_;
        }

        function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
            require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
            _tokenURIs[tokenId] = _tokenURI;
        }

        function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
        }

        function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory _tokenURI = _tokenURIs[tokenId];
            string memory base = _baseURI();

            // If there is no base URI, return the token URI.
            if (bytes(base).length == 0) {
                return _tokenURI;
            }
            // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
            if (bytes(_tokenURI).length > 0) {
                return string(abi.encodePacked(base, _tokenURI));
            }
            // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
            return string(abi.encodePacked(base, tokenId.toString()));
        }


        function mint(
            address _to,
            uint256 _tokenId,
            string memory tokenURI_
        ) external onlyOwner() {
            _mint(_to, _tokenId);
            _setTokenURI(_tokenId, tokenURI_);
        }
    }
