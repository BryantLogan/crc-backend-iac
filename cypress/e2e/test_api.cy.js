/// <reference types="cypress" />

describe ('Test visit count api', () => {
    it('fetches increaseCount', () => {
        cy.request('POST', '/')
        .then((resp) => {
            const data = resp.body;

            expect(resp.status).to.eq(200)

            expect(data.count).to.not.be.oneOf([null, "", undefined])
        })
    })
})