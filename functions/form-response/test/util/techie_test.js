const expect = require('chai').expect

const techie = require('../../util/techie')

describe('techie utils', () => {
  describe('processTechieMasterData', () => {
    it('throws away extra attributes', () => {
      const result = techie.processTechieMasterData({
        attributes: {
          id: 'ID',
          email: 'EMAIL',
          first_name: 'FIRST_NAME',
          last_name: null,
          state: 'APPLICANT',
          techie_key: 'Techie123',
          extra: 'EXTRA'
        },
        formAnswers: {}
      })
      expect(result).to.deep.equal({
        id: 'ID',
        email: 'EMAIL',
        first_name: 'FIRST_NAME',
        last_name: null,
        state: 'APPLICANT',
        techie_key: 'Techie123'
      })
    })
    it('adds non-existing source attributes', () => {
      expect(techie.processTechieMasterData({
        attributes: {
          first_name: 'Felix'
        },
        formAnswers: {
          email: {
            type: 'email',
            value: 'NEW'
          }
        }
      })).to.deep.equal({
        email: 'NEW',
        first_name: 'Felix'
      })
    })
    it('updates existing email', () => {
      expect(techie.processTechieMasterData({
        attributes: {
          email: 'OLD',
          first_name: 'Felix'
        },
        formAnswers: {
          email: {
            type: 'email',
            value: 'NEW'
          }
        }
      })).to.deep.equal({
        email: 'NEW',
        first_name: 'Felix'
      })
    })
    it('extracts firstName', () => {
      expect(techie.processTechieMasterData({
        attributes: {},
        formAnswers: {
          first_name: {
            type: 'text',
            value: 'NEW'
          }
        }
      })).to.deep.equal({
        first_name: 'NEW'
      })
    })
    it('extracts lastName', () => {
      expect(techie.processTechieMasterData({
        attributes: {},
        formAnswers: {
          last_name: {
            type: 'text',
            value: 'NEW'
          }
        }
      })).to.deep.equal({
        last_name: 'NEW'
      })
    })
  })
})