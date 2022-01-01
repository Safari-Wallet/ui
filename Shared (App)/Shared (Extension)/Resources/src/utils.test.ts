import { jest, describe, it, expect } from '@jest/globals';
import { $ } from './utils';

describe('utils', () => {
    describe('$', () => {
        let mockQuerySelector: () => Element | null;
        let mockQuerySelectorAll: () => NodeListOf<Element>;

        beforeEach(() => {
            mockQuerySelector = jest.fn();
            mockQuerySelectorAll = jest.fn();
            document.querySelector = mockQuerySelector;
            document.querySelectorAll = mockQuerySelectorAll;
        });

        it('should use querySelector for any queries beginning with a # symbol', () => {
            $('#test');
            expect(mockQuerySelector).toHaveBeenCalledWith('#test');
            expect(mockQuerySelectorAll).not.toHaveBeenCalled();
        });

        it('should use querySelectorAll for everything else', () => {
            $('body');
            $('.some-class');
            $('.some-class-name[with-attributes="and values"]');
            expect(mockQuerySelector).not.toHaveBeenCalled();
            expect(mockQuerySelectorAll).toHaveBeenCalledTimes(3);
        });
    });
});
