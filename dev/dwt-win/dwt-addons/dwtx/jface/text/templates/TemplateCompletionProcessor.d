/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module dwtx.jface.text.templates.TemplateCompletionProcessor;

import dwtx.jface.text.templates.SimpleTemplateVariableResolver; // packageimport
import dwtx.jface.text.templates.TemplateBuffer; // packageimport
import dwtx.jface.text.templates.TemplateContext; // packageimport
import dwtx.jface.text.templates.TemplateContextType; // packageimport
import dwtx.jface.text.templates.Template; // packageimport
import dwtx.jface.text.templates.TemplateVariable; // packageimport
import dwtx.jface.text.templates.PositionBasedCompletionProposal; // packageimport
import dwtx.jface.text.templates.TemplateException; // packageimport
import dwtx.jface.text.templates.TemplateTranslator; // packageimport
import dwtx.jface.text.templates.DocumentTemplateContext; // packageimport
import dwtx.jface.text.templates.GlobalTemplateVariables; // packageimport
import dwtx.jface.text.templates.InclusivePositionUpdater; // packageimport
import dwtx.jface.text.templates.TemplateProposal; // packageimport
import dwtx.jface.text.templates.ContextTypeRegistry; // packageimport
import dwtx.jface.text.templates.JFaceTextTemplateMessages; // packageimport
import dwtx.jface.text.templates.TextTemplateMessages; // packageimport
import dwtx.jface.text.templates.TemplateVariableType; // packageimport
import dwtx.jface.text.templates.TemplateVariableResolver; // packageimport


import dwt.dwthelper.utils;

import dwtx.dwtxhelper.Collection;




import dwt.graphics.Image;
import dwtx.jface.text.BadLocationException;
import dwtx.jface.text.IDocument;
import dwtx.jface.text.IRegion;
import dwtx.jface.text.ITextSelection;
import dwtx.jface.text.ITextViewer;
import dwtx.jface.text.Region;
import dwtx.jface.text.contentassist.ICompletionProposal;
import dwtx.jface.text.contentassist.IContentAssistProcessor;
import dwtx.jface.text.contentassist.IContextInformation;
import dwtx.jface.text.contentassist.IContextInformationValidator;


/**
 * A completion processor that computes template proposals. Subclasses need to
 * provide implementations for {@link #getTemplates(String)},
 * {@link #getContextType(ITextViewer, IRegion)} and {@link #getImage(Template)}.
 *
 * @since 3.0
 */
public abstract class TemplateCompletionProcessor : IContentAssistProcessor {

    private static final class ProposalComparator : Comparator {
        public int compare(Object o1, Object o2) {
            return (cast(TemplateProposal) o2).getRelevance() - (cast(TemplateProposal) o1).getRelevance();
        }
    }

    private static Comparator fgProposalComparator_;
    private static Comparator fgProposalComparator(){
        if(fgProposalComparator_ is null ) {
            synchronized( TemplateCompletionProcessor.classinfo ){
                if(fgProposalComparator_ is null ) {
                    fgProposalComparator_ = new ProposalComparator();
                }
            }
        }
        return fgProposalComparator_;
    }

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#computeCompletionProposals(dwtx.jface.text.ITextViewer,
     *      int)
     */
    public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer, int offset) {

        ITextSelection selection= cast(ITextSelection) viewer.getSelectionProvider().getSelection();

        // adjust offset to end of normalized selection
        if (selection.getOffset() is offset)
            offset= selection.getOffset() + selection.getLength();

        String prefix= extractPrefix(viewer, offset);
        Region region= new Region(offset - prefix.length(), prefix.length());
        TemplateContext context= createContext(viewer, region);
        if (context is null)
            return new ICompletionProposal[0];

        context.setVariable("selection", selection.getText()); // name of the selection variables {line, word}_selection //$NON-NLS-1$

        Template[] templates= getTemplates(context.getContextType().getId());

        List matches= new ArrayList();
        for (int i= 0; i < templates.length; i++) {
            Template template_= templates[i];
            try {
                context.getContextType().validate(template_.getPattern());
            } catch (TemplateException e) {
                continue;
            }
            if (template_.matches(prefix, context.getContextType().getId()))
                matches.add( cast(Object) createProposal(template_, context, cast(IRegion) region, getRelevance(template_, prefix)));
        }

        Collections.sort(matches, fgProposalComparator);

        return arraycast!(ICompletionProposal)( matches.toArray());
    }

    /**
     * Creates a new proposal.
     * <p>
     * Forwards to {@link #createProposal(Template, TemplateContext, IRegion, int)}.
     * Do neither call nor override.
     * </p>
     *
     * @param template the template to be applied by the proposal
     * @param context the context for the proposal
     * @param region the region the proposal applies to
     * @param relevance the relevance of the proposal
     * @return a new <code>ICompletionProposal</code> for
     *         <code>template</code>
     * @deprecated use the version specifying <code>IRegion</code> as third parameter
     * @since 3.1
     */
    protected ICompletionProposal createProposal(Template template_, TemplateContext context, Region region, int relevance) {
        return createProposal(template_, context, cast(IRegion) region, relevance);
    }

    /**
     * Creates a new proposal.
     * <p>
     * The default implementation returns an instance of
     * {@link TemplateProposal}. Subclasses may replace this method to provide
     * their own implementations.
     * </p>
     *
     * @param template the template to be applied by the proposal
     * @param context the context for the proposal
     * @param region the region the proposal applies to
     * @param relevance the relevance of the proposal
     * @return a new <code>ICompletionProposal</code> for
     *         <code>template</code>
     */
    protected ICompletionProposal createProposal(Template template_, TemplateContext context, IRegion region, int relevance) {
        return new TemplateProposal(template_, context, region, getImage(template_), relevance);
    }

    /**
     * Returns the templates valid for the context type specified by <code>contextTypeId</code>.
     *
     * @param contextTypeId the context type id
     * @return the templates valid for this context type id
     */
    protected abstract Template[] getTemplates(String contextTypeId);

    /**
     * Creates a concrete template context for the given region in the document. This involves finding out which
     * context type is valid at the given location, and then creating a context of this type. The default implementation
     * returns a <code>DocumentTemplateContext</code> for the context type at the given location.
     *
     * @param viewer the viewer for which the context is created
     * @param region the region into <code>document</code> for which the context is created
     * @return a template context that can handle template insertion at the given location, or <code>null</code>
     */
    protected TemplateContext createContext(ITextViewer viewer, IRegion region) {
        TemplateContextType contextType= getContextType(viewer, region);
        if (contextType !is null) {
            IDocument document= viewer.getDocument();
            return new DocumentTemplateContext(contextType, document, region.getOffset(), region.getLength());
        }
        return null;
    }

    /**
     * Returns the context type that can handle template insertion at the given region
     * in the viewer's document.
     *
     * @param viewer the text viewer
     * @param region the region into the document displayed by viewer
     * @return the context type that can handle template expansion for the given location, or <code>null</code> if none exists
     */
    protected abstract TemplateContextType getContextType(ITextViewer viewer, IRegion region);

    /**
     * Returns the relevance of a template given a prefix. The default
     * implementation returns a number greater than zero if the template name
     * starts with the prefix, and zero otherwise.
     *
     * @param template the template to compute the relevance for
     * @param prefix the prefix after which content assist was requested
     * @return the relevance of <code>template</code>
     * @see #extractPrefix(ITextViewer, int)
     */
    protected int getRelevance(Template template_, String prefix) {
        if (template_.getName().startsWith(prefix))
            return 90;
        return 0;
    }

    /**
     * Heuristically extracts the prefix used for determining template relevance
     * from the viewer's document. The default implementation returns the String from
     * offset backwards that forms a java identifier.
     *
     * @param viewer the viewer
     * @param offset offset into document
     * @return the prefix to consider
     * @see #getRelevance(Template, String)
     */
    protected String extractPrefix(ITextViewer viewer, int offset) {
        int i= offset;
        IDocument document= viewer.getDocument();
        if (i > document.getLength())
            return ""; //$NON-NLS-1$

        try {
            while (i > 0) {
                char ch= document.getChar(i - 1);
                if (!Character.isJavaIdentifierPart(ch))
                    break;
                i--;
            }

            return document.get(i, offset - i);
        } catch (BadLocationException e) {
            return ""; //$NON-NLS-1$
        }
    }

    /**
     * Returns the image to be used for the proposal for <code>template</code>.
     *
     * @param template the template for which an image should be returned
     * @return the image for <code>template</code>
     */
    protected abstract Image getImage(Template template_);

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#computeContextInformation(dwtx.jface.text.ITextViewer, int)
     */
    public IContextInformation[] computeContextInformation(ITextViewer viewer, int documentOffset) {
        return null;
    }

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#getCompletionProposalAutoActivationCharacters()
     */
    public char[] getCompletionProposalAutoActivationCharacters() {
        return null;
    }

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#getContextInformationAutoActivationCharacters()
     */
    public char[] getContextInformationAutoActivationCharacters() {
        return null;
    }

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#getErrorMessage()
     */
    public String getErrorMessage() {
        return null;
    }

    /*
     * @see dwtx.jface.text.contentassist.IContentAssistProcessor#getContextInformationValidator()
     */
    public IContextInformationValidator getContextInformationValidator() {
        return null;
    }
}
