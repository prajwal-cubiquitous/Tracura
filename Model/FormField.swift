//
//  FormField.swift
//  Tracura
//
//  Created by Prajwal S S Reddy on 12/23/25.
//

import Foundation

struct FormField {
    let key: String              // Must match Expense property name
    let aliases: [String]        // Possible labels in receipt/image
}


 //Expense form Field
let fixedExpenseFields: [FormField] = [

    // MARK: - Core Expense Info
    FormField(
        key: "projectId",
        aliases: ["project id", "project code", "project"]
    ),

    FormField(
        key: "date",
        aliases: ["date", "expense date", "bill date"]
    ),

    FormField(
        key: "amount",
        aliases: ["amount", "total amount", "amount paid", "total"]
    ),

    FormField(
        key: "department",
        aliases: ["department", "dept", "division"]
    ),

    FormField(
        key: "phaseId",
        aliases: ["phase id", "phase code"]
    ),

    FormField(
        key: "phaseName",
        aliases: ["phase name", "phase"]
    ),

    FormField(
        key: "categories",
        aliases: ["category", "categories", "expense type"]
    ),

    FormField(
        key: "modeOfPayment",
        aliases: ["mode of payment", "payment mode", "paid via"]
    ),

    FormField(
        key: "description",
        aliases: ["description", "details", "remarks", "purpose"]
    ),

    // MARK: - Attachments
    FormField(
        key: "attachmentName",
        aliases: ["attachment", "invoice", "bill copy"]
    ),

    FormField(
        key: "paymentProofName",
        aliases: ["payment proof", "upi proof", "cheque copy"]
    ),

    // MARK: - Submission Info
    FormField(
        key: "submittedBy",
        aliases: ["submitted by", "employee", "phone", "mobile"]
    ),

    // MARK: - Material Details (Optional)
    FormField(
        key: "itemType",
        aliases: ["item type", "sub category"]
    ),

    FormField(
        key: "item",
        aliases: ["item", "material"]
    ),

    FormField(
        key: "brand",
        aliases: ["brand", "make"]
    ),

    FormField(
        key: "spec",
        aliases: ["spec", "grade", "specification"]
    ),

    FormField(
        key: "thickness",
        aliases: ["thickness", "size"]
    ),

    FormField(
        key: "quantity",
        aliases: ["quantity", "qty"]
    ),

    FormField(
        key: "uom",
        aliases: ["uom", "unit", "unit of measure"]
    ),

    FormField(
        key: "unitPrice",
        aliases: ["unit price", "rate", "price per unit"]
    ),

    // MARK: - Approval & Status
    FormField(
        key: "status",
        aliases: ["status", "approval status"]
    ),

    FormField(
        key: "remark",
        aliases: ["remark", "approval remark", "comment"]
    ),

    FormField(
        key: "approvedBy",
        aliases: ["approved by", "approver"]
    ),

    FormField(
        key: "rejectedBy",
        aliases: ["rejected by", "rejected"]
    ),

    // MARK: - Anonymous Department Tracking
    FormField(
        key: "isAnonymous",
        aliases: ["anonymous", "anonymous department"]
    ),

    FormField(
        key: "originalDepartment",
        aliases: ["original department", "previous department"]
    )
]

