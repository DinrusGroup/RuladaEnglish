/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/


module dwtx.jface.text.rules.RuleBasedScanner;

import dwtx.jface.text.rules.FastPartitioner; // packageimport
import dwtx.jface.text.rules.ITokenScanner; // packageimport
import dwtx.jface.text.rules.Token; // packageimport
import dwtx.jface.text.rules.EndOfLineRule; // packageimport
import dwtx.jface.text.rules.WordRule; // packageimport
import dwtx.jface.text.rules.WhitespaceRule; // packageimport
import dwtx.jface.text.rules.WordPatternRule; // packageimport
import dwtx.jface.text.rules.IPredicateRule; // packageimport
import dwtx.jface.text.rules.DefaultPartitioner; // packageimport
import dwtx.jface.text.rules.NumberRule; // packageimport
import dwtx.jface.text.rules.SingleLineRule; // packageimport
import dwtx.jface.text.rules.PatternRule; // packageimport
import dwtx.jface.text.rules.RuleBasedDamagerRepairer; // packageimport
import dwtx.jface.text.rules.ICharacterScanner; // packageimport
import dwtx.jface.text.rules.IRule; // packageimport
import dwtx.jface.text.rules.DefaultDamagerRepairer; // packageimport
import dwtx.jface.text.rules.IToken; // packageimport
import dwtx.jface.text.rules.IPartitionTokenScanner; // packageimport
import dwtx.jface.text.rules.MultiLineRule; // packageimport
import dwtx.jface.text.rules.RuleBasedPartitioner; // packageimport
import dwtx.jface.text.rules.RuleBasedPartitionScanner; // packageimport
import dwtx.jface.text.rules.BufferedRuleBasedScanner; // packageimport
import dwtx.jface.text.rules.IWhitespaceDetector; // packageimport

import dwt.dwthelper.utils;



import dwtx.core.runtime.Assert;
import dwtx.jface.text.BadLocationException;
import dwtx.jface.text.IDocument;


/**
 * A generic scanner which can be "programmed" with a sequence of rules.
 * The scanner is used to get the next token by evaluating its rule in sequence until
 * one is successful. If a rule returns a token which is undefined, the scanner will proceed to
 * the next rule. Otherwise the token provided by the rule will be returned by
 * the scanner. If no rule returned a defined token, this scanner returns a token
 * which returns <code>true</code> when calling <code>isOther</code>, unless the end
 * of the file is reached. In this case the token returns <code>true</code> when calling
 * <code>isEOF</code>.
 *
 * @see IRule
 */
public class RuleBasedScanner : ICharacterScanner, ITokenScanner {

    /** The list of rules of this scanner */
    protected IRule[] fRules;
    /** The token to be returned by default if no rule fires */
    protected IToken fDefaultReturnToken;
    /** The document to be scanned */
    protected IDocument fDocument;
    /** The cached legal line delimiters of the document */
    protected char[][] fDelimiters;
    /** The offset of the next character to be read */
    protected int fOffset;
    /** The end offset of the range to be scanned */
    protected int fRangeEnd;
    /** The offset of the last read token */
    protected int fTokenOffset;
    /** The cached column of the current scanner position */
    protected int fColumn;
    /** Internal setting for the un-initialized column cache. */
    protected static final int UNDEFINED= -1;

    /**
     * Creates a new rule based scanner which does not have any rule.
     */
    public this() {
    }

    /**
     * Configures the scanner with the given sequence of rules.
     *
     * @param rules the sequence of rules controlling this scanner
     */
    public void setRules(IRule[] rules) {
        if (rules !is null) {
            fRules= new IRule[rules.length];
            SimpleType!(IRule).arraycopy(rules, 0, fRules, 0, rules.length);
        } else
            fRules= null;
    }

    /**
     * Configures the scanner's default return token. This is the token
     * which is returned when none of the rules fired and EOF has not been
     * reached.
     *
     * @param defaultReturnToken the default return token
     * @since 2.0
     */
    public void setDefaultReturnToken(IToken defaultReturnToken) {
        Assert.isNotNull(defaultReturnToken.getData());
        fDefaultReturnToken= defaultReturnToken;
    }

    /*
     * @see ITokenScanner#setRange(IDocument, int, int)
     */
    public void setRange(IDocument document, int offset, int length) {
        Assert.isLegal(document !is null);
        final int documentLength= document.getLength();
        checkRange(offset, length, documentLength);

        fDocument= document;
        fOffset= offset;
        fColumn= UNDEFINED;
        fRangeEnd= offset + length;

        String[] delimiters= fDocument.getLegalLineDelimiters();
        fDelimiters= new char[][](delimiters.length);
        for (int i= 0; i < delimiters.length; i++)
            fDelimiters[i]= delimiters[i].toCharArray();

        if (fDefaultReturnToken is null)
            fDefaultReturnToken= new Token(null);
    }

    /**
     * Checks that the given range is valid.
     * See https://bugs.eclipse.org/bugs/show_bug.cgi?id=69292
     *
     * @param offset the offset of the document range to scan
     * @param length the length of the document range to scan
     * @param documentLength the document's length
     * @since 3.3
     */
    private void checkRange(int offset, int length, int documentLength) {
        Assert.isLegal(offset > -1);
        Assert.isLegal(length > -1);
        Assert.isLegal(offset + length <= documentLength);
    }

    /*
     * @see ITokenScanner#getTokenOffset()
     */
    public int getTokenOffset() {
        return fTokenOffset;
    }

    /*
     * @see ITokenScanner#getTokenLength()
     */
    public int getTokenLength() {
        if (fOffset < fRangeEnd)
            return fOffset - getTokenOffset();
        return fRangeEnd - getTokenOffset();
    }


    /*
     * @see ICharacterScanner#getColumn()
     */
    public int getColumn() {
        if (fColumn is UNDEFINED) {
            try {
                int line= fDocument.getLineOfOffset(fOffset);
                int start= fDocument.getLineOffset(line);

                fColumn= fOffset - start;

            } catch (BadLocationException ex) {
            }
        }
        return fColumn;
    }

    /*
     * @see ICharacterScanner#getLegalLineDelimiters()
     */
    public char[][] getLegalLineDelimiters() {
        return fDelimiters;
    }

    /*
     * @see ITokenScanner#nextToken()
     */
    public IToken nextToken() {

        fTokenOffset= fOffset;
        fColumn= UNDEFINED;

        if (fRules !is null) {
            for (int i= 0; i < fRules.length; i++) {
                IToken token= (fRules[i].evaluate(this));
                if (!token.isUndefined())
                    return token;
            }
        }

        if (read() is EOF)
            return Token.EOF;
        return fDefaultReturnToken;
    }

    /*
     * @see ICharacterScanner#read()
     */
    public int read() {

        try {

            if (fOffset < fRangeEnd) {
                try {
                    return fDocument.getChar(fOffset);
                } catch (BadLocationException e) {
                }
            }

            return EOF;

        } finally {
            ++ fOffset;
            fColumn= UNDEFINED;
        }
    }

    /*
     * @see ICharacterScanner#unread()
     */
    public void unread() {
        --fOffset;
        fColumn= UNDEFINED;
    }
}


