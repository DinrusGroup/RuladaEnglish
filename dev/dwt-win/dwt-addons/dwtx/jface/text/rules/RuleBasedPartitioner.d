/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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


module dwtx.jface.text.rules.RuleBasedPartitioner;

import dwtx.jface.text.rules.FastPartitioner; // packageimport
import dwtx.jface.text.rules.ITokenScanner; // packageimport
import dwtx.jface.text.rules.Token; // packageimport
import dwtx.jface.text.rules.RuleBasedScanner; // packageimport
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
import dwtx.jface.text.rules.RuleBasedPartitionScanner; // packageimport
import dwtx.jface.text.rules.BufferedRuleBasedScanner; // packageimport
import dwtx.jface.text.rules.IWhitespaceDetector; // packageimport

import dwt.dwthelper.utils;


import dwtx.dwtxhelper.Collection;


import dwtx.core.runtime.Assert;
import dwtx.jface.text.BadLocationException;
import dwtx.jface.text.BadPositionCategoryException;
import dwtx.jface.text.DefaultPositionUpdater;
import dwtx.jface.text.DocumentEvent;
import dwtx.jface.text.IDocument;
import dwtx.jface.text.IDocumentPartitioner;
import dwtx.jface.text.IDocumentPartitionerExtension;
import dwtx.jface.text.IDocumentPartitionerExtension2;
import dwtx.jface.text.IRegion;
import dwtx.jface.text.ITypedRegion;
import dwtx.jface.text.Position;
import dwtx.jface.text.Region;
import dwtx.jface.text.TextUtilities;
import dwtx.jface.text.TypedPosition;
import dwtx.jface.text.TypedRegion;



/**
 * A standard implementation of a syntax driven document partitioner.
 * It uses a rule based scanner to scan the document and to determine
 * the document's partitioning. The tokens returned by the rules the
 * scanner is configured with are supposed to return the partition type
 * as their data. The partitioner remembers the document's partitions
 * in the document itself rather than maintaining its own data structure.
 *
 * @see IRule
 * @see RuleBasedScanner
 *
 * @deprecated use <code>FastPartitioner</code> instead
 */
public class RuleBasedPartitioner : IDocumentPartitioner, IDocumentPartitionerExtension, IDocumentPartitionerExtension2 {

    /**
     * The position category this partitioner uses to store the document's partitioning information
     * @deprecated As of 3.0, use <code>getManagingPositionCategories()</code>.
     */
    public const static String CONTENT_TYPES_CATEGORY= "__content_types_category"; //$NON-NLS-1$


    /** The partitioner's scanner */
    protected RuleBasedScanner fScanner;
    /** The legal content types of this partitioner */
    protected String[] fLegalContentTypes;
    /** The partitioner's document */
    protected IDocument fDocument;
    /** The document length before a document change occurred */
    protected int fPreviousDocumentLength;
    /** The position updater used to for the default updating of partitions */
    protected DefaultPositionUpdater fPositionUpdater;
    /** The offset at which the first changed partition starts */
    protected int fStartOffset;
    /** The offset at which the last changed partition ends */
    protected int fEndOffset;
    /**The offset at which a partition has been deleted */
    protected int fDeleteOffset;
    /**
     * The position category for managing partitioning information.
     * @since 3.0
     */
    private String fPositionCategory;


    /**
     * Creates a new partitioner that uses the given scanner and may return
     * partitions of the given legal content types.
     *
     * @param scanner the scanner this partitioner is supposed to use
     * @param legalContentTypes the legal content types of this partitioner
     */
    public this(RuleBasedScanner scanner, String[] legalContentTypes) {
        fScanner= scanner;
        fLegalContentTypes= TextUtilities.copy(legalContentTypes);
        fPositionCategory= CONTENT_TYPES_CATEGORY ~ Integer.toString(toHash());
        fPositionUpdater= new DefaultPositionUpdater(fPositionCategory);
    }

    /*
     * @see dwtx.jface.text.IDocumentPartitionerExtension2#getManagingPositionCategories()
     * @since 3.0
     */
    public String[] getManagingPositionCategories() {
        return [ fPositionCategory ];
    }

    /*
     * @see IDocumentPartitioner#connect
     */
    public void connect(IDocument document) {
        Assert.isNotNull(cast(Object)document);
        Assert.isTrue(!document.containsPositionCategory(fPositionCategory));

        fDocument= document;
        fDocument.addPositionCategory(fPositionCategory);

        initialize();
    }

    /**
     * Performs the initial partitioning of the partitioner's document.
     */
    protected void initialize() {

        fScanner.setRange(fDocument, 0, fDocument.getLength());

        try {
            IToken token= fScanner.nextToken();
            while (!token.isEOF()) {

                String contentType= getTokenContentType(token);

                if (isSupportedContentType(contentType)) {
                    TypedPosition p= new TypedPosition(fScanner.getTokenOffset(), fScanner.getTokenLength(), contentType);
                    fDocument.addPosition(fPositionCategory, p);
                }

                token= fScanner.nextToken();
            }
        } catch (BadLocationException x) {
            // cannot happen as offsets come from scanner
        } catch (BadPositionCategoryException x) {
            // cannot happen if document has been connected before
        }
    }

    /*
     * @see IDocumentPartitioner#disconnect
     */
    public void disconnect() {

        Assert.isTrue(fDocument.containsPositionCategory(fPositionCategory));

        try {
            fDocument.removePositionCategory(fPositionCategory);
        } catch (BadPositionCategoryException x) {
            // can not happen because of Assert
        }
    }

    /*
     * @see IDocumentPartitioner#documentAboutToBeChanged
     */
    public void documentAboutToBeChanged(DocumentEvent e) {

        Assert.isTrue(e.getDocument() is fDocument);

        fPreviousDocumentLength= e.getDocument().getLength();
        fStartOffset= -1;
        fEndOffset= -1;
        fDeleteOffset= -1;
    }

    /*
     * @see IDocumentPartitioner#documentChanged
     */
    public bool documentChanged(DocumentEvent e) {
        IRegion region= documentChanged2(e);
        return (region !is null);
    }

    /**
     * Helper method for tracking the minimal region containing all partition changes.
     * If <code>offset</code> is smaller than the remembered offset, <code>offset</code>
     * will from now on be remembered. If <code>offset  + length</code> is greater than
     * the remembered end offset, it will be remembered from now on.
     *
     * @param offset the offset
     * @param length the length
     */
    private void rememberRegion(int offset, int length) {
        // remember start offset
        if (fStartOffset is -1)
            fStartOffset= offset;
        else if (offset < fStartOffset)
            fStartOffset= offset;

        // remember end offset
        int endOffset= offset + length;
        if (fEndOffset is -1)
            fEndOffset= endOffset;
        else if (endOffset > fEndOffset)
            fEndOffset= endOffset;
    }

    /**
     * Remembers the given offset as the deletion offset.
     *
     * @param offset the offset
     */
    private void rememberDeletedOffset(int offset) {
        fDeleteOffset= offset;
    }

    /**
     * Creates the minimal region containing all partition changes using the
     * remembered offset, end offset, and deletion offset.
     * @return the minimal region containing all the partition changes
     */
    private IRegion createRegion() {
        if (fDeleteOffset is -1) {
            if (fStartOffset is -1 || fEndOffset is -1)
                return null;
            return new Region(fStartOffset, fEndOffset - fStartOffset);
        } else if (fStartOffset is -1 || fEndOffset is -1) {
            return new Region(fDeleteOffset, 0);
        } else {
            int offset= Math.min(fDeleteOffset, fStartOffset);
            int endOffset= Math.max(fDeleteOffset, fEndOffset);
            return new Region(offset, endOffset - offset);
        }
    }

    /*
     * @see IDocumentPartitionerExtension#documentChanged2(DocumentEvent)
     * @since 2.0
     */
    public IRegion documentChanged2(DocumentEvent e) {

        try {

            IDocument d= e.getDocument();
            Position[] category= d.getPositions(fPositionCategory);
            int first= 0;
            int reparseStart= 0;
            int originalSize= category.length;

            if (originalSize > 0) {

                /*
                 * determine character position at which the scanner starts:
                 * first position behind the last non-default partition the actual position is not involved with
                 */

                first= d.computeIndexInCategory(fPositionCategory, e.getOffset());

                Position p= null;
                do {
                    --first;
                    if (first < 0)
                        break;

                    p= category[first];

                } while (p.overlapsWith(e.getOffset(), e.getLength()) ||
                            (e.getOffset() is fPreviousDocumentLength &&
                             (p.getOffset() + p.getLength() is fPreviousDocumentLength)));

                fPositionUpdater.update(e);
                for (int i= 0; i < category.length; i++) {
                    p= category[i];
                    if (p.isDeleted) {
                        rememberDeletedOffset(e.getOffset());
                        break;
                    }
                }
                category= d.getPositions(fPositionCategory);

                if (first >= 0) {
                    p= category[first];
                    reparseStart= p.getOffset() + p.getLength();
                }

                ++first;
            }

            fScanner.setRange(d, reparseStart, d.getLength() - reparseStart);

            int lastScannedPosition= reparseStart;
            IToken token= fScanner.nextToken();

            while (!token.isEOF()) {


                String contentType= getTokenContentType(token);

                if (!isSupportedContentType(contentType)) {
                    token= fScanner.nextToken();
                    continue;
                }

                int start= fScanner.getTokenOffset();
                int length= fScanner.getTokenLength();

                lastScannedPosition= start + length - 1;

                // remove all affected positions
                while (first < category.length) {
                    TypedPosition p= cast(TypedPosition) category[first];
                    if (lastScannedPosition >= p.offset + p.length ||
                            (p.overlapsWith(start, length) &&
                                (!d.containsPosition(fPositionCategory, start, length) ||
                                 !contentType.equals(p.getType())))) {

                        rememberRegion(p.offset, p.length);
                        d.removePosition(fPositionCategory, p);
                        ++ first;

                    } else
                        break;
                }

                // if position already exists we are done
                if (d.containsPosition(fPositionCategory, start, length))
                    return createRegion();

                // insert the new type position
                try {
                    d.addPosition(fPositionCategory, new TypedPosition(start, length, contentType));
                    rememberRegion(start, length);
                } catch (BadPositionCategoryException x) {
                } catch (BadLocationException x) {
                }

                token= fScanner.nextToken();
            }


            // remove all positions behind lastScannedPosition since there aren't any further types
            if (lastScannedPosition !is reparseStart) {
                // if this condition is not met, nothing has been scanned because of a delete
                ++ lastScannedPosition;
            }
            first= d.computeIndexInCategory(fPositionCategory, lastScannedPosition);

            TypedPosition p;
            while (first < category.length) {
                p= cast(TypedPosition) category[first++];
                d.removePosition(fPositionCategory, p);
                rememberRegion(p.offset, p.length);
            }

        } catch (BadPositionCategoryException x) {
            // should never happen on connected documents
        } catch (BadLocationException x) {
        }

        return createRegion();
    }


    /**
     * Returns the position in the partitoner's position category which is
     * close to the given offset. This is, the position has either an offset which
     * is the same as the given offset or an offset which is smaller than the given
     * offset. This method profits from the knowledge that a partitioning is
     * a ordered set of disjoint position.
     *
     * @param offset the offset for which to search the closest position
     * @return the closest position in the partitioner's category
     */
    protected TypedPosition findClosestPosition(int offset) {

        try {

            int index= fDocument.computeIndexInCategory(fPositionCategory, offset);
            Position[] category= fDocument.getPositions(fPositionCategory);

            if (category.length is 0)
                return null;

            if (index < category.length) {
                if (offset is category[index].offset)
                    return cast(TypedPosition) category[index];
            }

            if (index > 0)
                index--;

            return cast(TypedPosition) category[index];

        } catch (BadPositionCategoryException x) {
        } catch (BadLocationException x) {
        }

        return null;
    }


    /*
     * @see IDocumentPartitioner#getContentType
     */
    public String getContentType(int offset) {

        TypedPosition p= findClosestPosition(offset);
        if (p !is null && p.includes(offset))
            return p.getType();

        return IDocument.DEFAULT_CONTENT_TYPE;
    }

    /*
     * @see IDocumentPartitioner#getPartition
     */
    public ITypedRegion getPartition(int offset) {

        try {

            Position[] category = fDocument.getPositions(fPositionCategory);

            if (category is null || category.length is 0)
                return new TypedRegion(0, fDocument.getLength(), IDocument.DEFAULT_CONTENT_TYPE);

            int index= fDocument.computeIndexInCategory(fPositionCategory, offset);

            if (index < category.length) {

                TypedPosition next= cast(TypedPosition) category[index];

                if (offset is next.offset)
                    return new TypedRegion(next.getOffset(), next.getLength(), next.getType());

                if (index is 0)
                    return new TypedRegion(0, next.offset, IDocument.DEFAULT_CONTENT_TYPE);

                TypedPosition previous= cast(TypedPosition) category[index - 1];
                if (previous.includes(offset))
                    return new TypedRegion(previous.getOffset(), previous.getLength(), previous.getType());

                int endOffset= previous.getOffset() + previous.getLength();
                return new TypedRegion(endOffset, next.getOffset() - endOffset, IDocument.DEFAULT_CONTENT_TYPE);
            }

            TypedPosition previous= cast(TypedPosition) category[category.length - 1];
            if (previous.includes(offset))
                return new TypedRegion(previous.getOffset(), previous.getLength(), previous.getType());

            int endOffset= previous.getOffset() + previous.getLength();
            return new TypedRegion(endOffset, fDocument.getLength() - endOffset, IDocument.DEFAULT_CONTENT_TYPE);

        } catch (BadPositionCategoryException x) {
        } catch (BadLocationException x) {
        }

        return new TypedRegion(0, fDocument.getLength(), IDocument.DEFAULT_CONTENT_TYPE);
    }

    /*
     * @see IDocumentPartitioner#computePartitioning
     */
    public ITypedRegion[] computePartitioning(int offset, int length) {
        return computePartitioning(offset, length, false);
    }

    /*
     * @see IDocumentPartitioner#getLegalContentTypes
     */
    public String[] getLegalContentTypes() {
        return TextUtilities.copy(fLegalContentTypes);
    }

    /**
     * Returns whether the given type is one of the legal content types.
     *
     * @param contentType the content type to check
     * @return <code>true</code> if the content type is a legal content type
     */
    protected bool isSupportedContentType(String contentType) {
        if (contentType !is null) {
            for (int i= 0; i < fLegalContentTypes.length; i++) {
                if (fLegalContentTypes[i].equals(contentType))
                    return true;
            }
        }

        return false;
    }

    /**
     * Returns a content type encoded in the given token. If the token's
     * data is not <code>null</code> and a string it is assumed that
     * it is the encoded content type.
     *
     * @param token the token whose content type is to be determined
     * @return the token's content type
     */
    protected String getTokenContentType(IToken token) {
        Object data= token.getData();
        if ( auto str = cast(ArrayWrapperString)data )
            return str.array;
        return null;
    }

    /* zero-length partition support */

    /*
     * @see dwtx.jface.text.IDocumentPartitionerExtension2#getContentType(int)
     * @since 3.0
     */
    public String getContentType(int offset, bool preferOpenPartitions) {
        return getPartition(offset, preferOpenPartitions).getType();
    }

    /*
     * @see dwtx.jface.text.IDocumentPartitionerExtension2#getPartition(int)
     * @since 3.0
     */
    public ITypedRegion getPartition(int offset, bool preferOpenPartitions) {
        ITypedRegion region= getPartition(offset);
        if (preferOpenPartitions) {
            if (region.getOffset() is offset && !region.getType().equals(IDocument.DEFAULT_CONTENT_TYPE)) {
                if (offset > 0) {
                    region= getPartition(offset - 1);
                    if (region.getType().equals(IDocument.DEFAULT_CONTENT_TYPE))
                        return region;
                }
                return new TypedRegion(offset, 0, IDocument.DEFAULT_CONTENT_TYPE);
            }
        }
        return region;
    }

    /*
     * @see dwtx.jface.text.IDocumentPartitionerExtension2#computePartitioning(int, int)
     * @since 3.0
     */
    public ITypedRegion[] computePartitioning(int offset, int length, bool includeZeroLengthPartitions) {
        List list= new ArrayList();

        try {

            int endOffset= offset + length;

            Position[] category= fDocument.getPositions(fPositionCategory);

            TypedPosition previous= null, current= null;
            int start, end, gapOffset;
            Position gap= null;

            for (int i= 0; i < category.length; i++) {

                current= cast(TypedPosition) category[i];

                gapOffset= (previous !is null) ? previous.getOffset() + previous.getLength() : 0;
                gap= new Position(gapOffset, current.getOffset() - gapOffset);
                if ((includeZeroLengthPartitions || gap.getLength() > 0) && gap.overlapsWith(offset, length)) {
                    start= Math.max(offset, gapOffset);
                    end= Math.min(endOffset, gap.getOffset() + gap.getLength());
                    list.add(new TypedRegion(start, end - start, IDocument.DEFAULT_CONTENT_TYPE));
                }

                if (current.overlapsWith(offset, length)) {
                    start= Math.max(offset, current.getOffset());
                    end= Math.min(endOffset, current.getOffset() + current.getLength());
                    list.add(new TypedRegion(start, end - start, current.getType()));
                }

                previous= current;
            }

            if (previous !is null) {
                gapOffset= previous.getOffset() + previous.getLength();
                gap= new Position(gapOffset, fDocument.getLength() - gapOffset);
                if ((includeZeroLengthPartitions || gap.getLength() > 0) && ((includeZeroLengthPartitions && offset + length is gapOffset && gap.length is 0) || gap.overlapsWith(offset, length))) {
                    start= Math.max(offset, gapOffset);
                    end= Math.min(endOffset, fDocument.getLength());
                    list.add(new TypedRegion(start, end - start, IDocument.DEFAULT_CONTENT_TYPE));
                }
            }

            if (list.isEmpty())
                list.add(new TypedRegion(offset, length, IDocument.DEFAULT_CONTENT_TYPE));

        } catch (BadPositionCategoryException x) {
        }

        return arraycast!(ITypedRegion)(list.toArray());
    }
}
