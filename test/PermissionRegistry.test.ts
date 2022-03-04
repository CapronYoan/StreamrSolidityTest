import { expect, use } from 'chai'
import { deployContract, MockProvider, solidity } from 'ethereum-waffle'
import { Contract, utils, Wallet, ethers} from 'ethers'

import PermissionRegistry from '../build/PermissionRegistry.json'

use(solidity)

let registry: Contract

const createItem = async(_id: string, _description: string): Promise<boolean>  => {
    return new Promise (async (resolve): Promise<void> => {
        try {
            
            const tx = await registry.createItem(_id, _description)
            const receipt = await tx.wait()
            if(receipt.status === 1){
                resolve(true)
            } else {
                resolve(false)
            }
        } catch (e) {
            // console.log(e)
            resolve(false)
        }
    })
}



const grantPermissions = async(_id: string, _user: Wallet, _permission: number): Promise<boolean>  => {
    return new Promise (async (resolve): Promise<void> => {
        try {
            
            const tx = await registry.grantPermissions(_id, _user.address ,_permission)
            const receipt = await tx.wait()
            if(receipt.status === 1){
                resolve(true)
            } else {
                resolve(false)
            }
        } catch (e) {
            console.log(e)
            resolve(false)
        }
    })
}



describe('PermissionRegistry', (): void => { 
    //10 test wallets
    const wallets = new MockProvider().getWallets()
    

    before(async (): Promise<void> => {
        registry = await deployContract(wallets[0], PermissionRegistry)
    })

    after(() => process.exit())



    let bool0: boolean
    before(async (): Promise<void> => {
        bool0 = await createItem("1", "blabla")
    })
    it('should let you create item', async (): Promise<void> => {
        expect(bool0).to.equal(true);
    })  




    let bool1: boolean
    before(async (): Promise<void> => {
        bool1 = await grantPermissions("1", wallets[1], 3)
    })
    it('should let you grant permission', async (): Promise<void> => {
        expect(bool1).to.equal(true);
    })



    it('should not let you grant permission', async (): Promise<void> => {
        const contractAddress2 = registry.connect(wallets[2]) // change to address 2
        await expect(contractAddress2.grantPermissions("1", wallets[3].address, 3,  {gasLimit: ethers.BigNumber.from("500000")}))
        .to.be.revertedWith("grantPermissions: user isn't granted.")
    })


  
    it('should not let you edit description', async (): Promise<void> => {
        const contractAddress2 = registry.connect(wallets[2]) // change to address 2
        await expect(contractAddress2.editItem("1", "foo", {gasLimit: ethers.BigNumber.from("500000")}))
        .to.be.revertedWith("editItem: user isn't allowed to edit.")
    })


   

    


    
  
})
